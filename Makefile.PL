use 5.005;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Deployka',
    VERSION_FROM      => 'lib/Deployka.pm', # finds $VERSION
    PREREQ_PM         => {'Const::Fast' => 0, 'LWP::UserAgent' => 0, 'YAML' => 0}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Deployka.pm', # retrieve abstract from module
       AUTHOR         => 'Alex Chistyakov <alexclear@gmail.com>') : ()),
);
