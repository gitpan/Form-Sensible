use inc::Module::Install;
  
# Define metadata
name            'Form-Sensible';
all_from        'lib/Form/Sensible.pm';

# Specific dependencies
requires        'Moose';
requires        'namespace::autoclean';
requires        'Class::MOP';
requires        'Data::Dumper';
requires        'Carp';
requires        'Template';
requires        'File::Sharedir';
requires        'FindBin';
test_requires   'Test::More'  => '0.42';
install_share   'share';
no_index        'directory'   => 'examples';
# Perhaps we will use this to create command-line based form generators... another day.
#install_script  'myscript';

WriteAll;