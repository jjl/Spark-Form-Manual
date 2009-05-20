package Spark::Form::Manual::Tutorial::GettingStarted;

1;
__END__

=head1 INSTALLATION

Spark::Form comes in a number of parts. It is recommended you install L<Bundle::Spark::Form> which will grab them all.

=head1 Diving in: My first form

 use Spark::Form;
 
 my $form = Spark::Form->new( printer => 'SparkX::Form::Printer::List' );
 $form->add('text','name');
 print $form->to_xhtml;

=head1 Taking it apart

 use Spark::Form;
 
 my $form = Spark::Form->new( printer => 'SparkX::Form::Printer::List' );

This creates a new C<Spark::Form> object and instructs it to use C<SparkX::Form::Printer::List> as a printer. A printer is used whenever we want to print out a form.
 
 $form->add('text','name');

This adds a field to the form. In this case we ask it for a 'text' field and give it the name 'name'.

 print $form->to_xhtml; #to_html is also supported

This prints out the form in XHTML.

=head1 Adding fields in depth

The 'add' method of C<Spark::Form> works in a number of ways. In its simplest form, it takes a field object and adds it to the form, extracting the name form the field. The way we have used it here, we asked it to automatically create a field by name. There are two parameters required for this: the name of the field type and the name you wish to assign to it.

I've used 'text' here, one of the fields from L<SparkX::BasicFields>. In much the same vein are C<checkbox>, C<password> etc. Take a look at L<SparkX::BasicFields> for the rest of them, there is a field for every type of form field permissible in XHTML and HTML4.

=head1 Printing

In L<Spark::Form>, printing is delegated to 'Printer' modules such as L<SparkX::Form::Printer::List>. In this example, we selected this module which spits out the code as an XHTML list. This module also has a to_html method which outputs HTML 4.

=head1 Validation

In the spirit of doing things properly, lets define a custom 'password' field which stipulates it cannot be shorter than 6 characters in length.

 package MyApp::Field::LongPassword;
 
 use Moose;
 require 'SparkX::Form::Field::Password';
 extends 'SparkX::Form::Field::Password';
 
 sub validate {
   if (length $self->value < 6) {
     $self->error("Your password must be at least 6 characters long");
   }
 } 

 use Spark::Form;
 
 my $form = Spark::Form->new( plugin_ns => 'MyApp::Field' );
 $form->add( 'LongPassword','pass' );
 #Mock up some cgi input
 my $input = {pass => 'blah'};
 $form->data($input);
 if($form->invalid) {
    print join("<br />", $form->errors);
 }
 
 Lets take this apart.

 package MyApp::Field::LongPassword;
 
 use Moose;
 require 'SparkX::Form::Field::Password';
 extends 'SparkX::Form::Field::Password';

Here we define our LongPassword field. To save effort, we'll base it on L<SparkX::Form::Field::Password>, which will implement C<to_xhtml> and C<to_html> for us.

 sub validate {
   if (length $self->value < 6) {
     $self->error("Your password must be at least 6 characters long");
   }
 } 

Here we define our validate method. A validate method is expected to do two things:
1. Set $self->valid(0) if the field is invalid.
2. Set an error message if the field is invalid.

Otherwise, it is assumed to be true. The C<error> method handily does both points for us if the field is invalid. Now lets go onto the form.

 use Spark::Form;
 
 my $form = Spark::Form->new( plugin_ns => 'MyApp::Field' );

This is just using the form as before. This time we pass it a 'plugin namespace', where it will try to autoload named modules from.

 $form->add( 'LongPassword','pass' );

Here we use the above feature to load our 'LongPassword' field.

 #Mock up some cgi input
 my $input = {pass => 'blah'};

For pedagogical purposes, I'm just going to assume you've processed CGI input and have a hash at your disposal.

 $form->data($input);

This sets the form data by hash-ref.

 if($form->invalid) {
    print join("<br />", $form->errors);
 }

If the form does not validate, we show a list of errors. In this case it will not validate and will show our error.

=head Tidying it up

Turns out minimum length is quite a common validation, so we made it easier.

 package MyApp::Field::LongPassword;
 
 use Moose;
 require 'SparkX::Form::Field::Password';
 extends 'SparkX::Form::Field::Password';
 
 require 'SparkX::Form::Field::Validator::MinLength';
 with 'SparkX::Form::Field::Validator::MinLength';
 
 has '+errmsg_too_short' => (
     default => "Your password must be at least 6 characters long",
 );
 
 has '+min_length' => (
     default => 6,
 );

=head2 Taking that apart

 package MyApp::Field::LongPassword;
 
 use Moose;
 require 'SparkX::Form::Field::Password';
 extends 'SparkX::Form::Field::Password';

Same as above. Nothing new.

 require 'SparkX::Form::Field::Validator::MinLength';
 with 'SparkX::Form::Field::Validator::MinLength';

Here we use the 'MinLength' validator mixin from L<SparkX::Form::BasicValidators>. It has two parameters you may want to configure.

 has '+errmsg_too_short' => (
     default => "Your password must be at least 6 characters long",
 );

This is the error message that will be shown if the input is too short.

 has '+min_length' => (
     default => 6,
 );

And this is the length the input must be.

=head1 One step further

Lets add a password confirm field. It should confirm that the confirm field matches the password field.

 package MyApp::Field::LongPassword;
 
 use Moose;
 require 'SparkX::Form::Field::Password';
 extends 'SparkX::Form::Field::Password';
 
 require 'SparkX::Form::Field::Validator::MinLength';
 with 'SparkX::Form::Field::Validator::MinLength';
 
 require 'SparkX::Form::Field::Validator::Confirm';
 with 'SparkX::Form::Field::Validator::Confirm';
 
 has '+errmsg_too_short' => (
     default => "Your password must be at least 6 characters long",
 );
 
 has '+min_length' => (
     default => 6,
 );
 
 has '+errmsg_confirm' => (
     default => 'Your password must match the confirm field',
 );

And the corresponding changes to the form.

 use Spark::Form;
 
 my $form = Spark::Form->new( plugin_ns => 'MyApp::Field' );
 $form->add( 'LongPassword','pass' )->add( 'LongPassword', 'confirm', confirm => 'pass' );
 #Mock up some cgi input
 my $input = {pass => 'foo', confirm => 'bar' };
 $form->data($input);
 if($form->invalid) {
    print join("<br />", $form->errors);
 }

=head2 Taking it apart once more

 package MyApp::Field::LongPassword;
 
 use Moose;
 require 'SparkX::Form::Field::Password';
 extends 'SparkX::Form::Field::Password';
 
 require 'SparkX::Form::Field::Validator::MinLength';
 with 'SparkX::Form::Field::Validator::MinLength';

Nothing new here

 require 'SparkX::Form::Field::Validator::Confirm';
 with 'SparkX::Form::Field::Validator::Confirm';

Here we mix in the C<Confirm> validator from L<SparkX::Form::BasicValidators>.

 has '+errmsg_too_short' => (
     default => "Your password must be at least 6 characters long",
 );
 
 has '+min_length' => (
     default => 6,
 );

Nothing new there

 has '+errmsg_confirm' => (
     default => 'Your password must match the confirm field',
 );

Customise the error message.

And the corresponding changes to the form.

 use Spark::Form;
 
 my $form = Spark::Form->new( plugin_ns => 'MyApp::Field' );

Nothing new so far

 $form->add( 'LongPassword','pass' )->add( 'LongPassword', 'confirm', confirm => 'pass', min_length => 0 );

Here we've added an extra LongPassword field. We also passed in extra keyword arguments, these will be passed to the field's constructor, which is just a Moose object. In this case we set the name of the confirm field. We also set the minimum length to 0 to avoid triggering another error while we very lazily don't bother seperately defining the confirm field.

 #Mock up some cgi input
 my $input = {pass => 'foo', confirm => 'bar' };
 $form->data($input);

We fake up some form input, making sure they don't match so you get a lovely error. Two errors in fact, one from each field. Each field is capable of multiple errors, however.

 if($form->invalid) {
    print join("<br />", $form->errors);
 }

Same as before.

=head1 SEE ALSO

L<Spark::Form> - the forms module that started it all
L<Spark::Form::Manual> - root of this dist
