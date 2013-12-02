use strict;			# Good practice
use warnings;			# Good practice
use WWW::Mechanize::Firefox;	# From CPAN
use JSON;			# From CPAN
use File::Path;			# From CPAN

## Variables
my $facebookAccountToGet = "xxxxxxx";
  # Credential to connect on facebook
my $facebookUser = '';
my $facebookPwd = '';
  # $exportUrlToFile if 1 export image url to url.txt else download image
my $exportUrlToFile = 0;
my $debug = 0;

my $fh;
my $count = 0;

## Get page https://www.facebook.com/xxxxxxx/photos_stream
my $mech = WWW::Mechanize::Firefox->new();
$mech->autoclose_tab( 1 );
$mech->get("https://www.facebook.com/$facebookAccountToGet/photos_stream");

if ($facebookUser ne "") {
    $mech->submit_form( with_fields => { email => $facebookUser, pass => $facebookPwd});
    sleep(1);
}

## Scroll to load every photo
my ($window,$type) = $mech->eval('window');
$window->scrollByLines(13);
$window->scrollByLines(120);
sleep(3);
$window->scrollByLines(120);
sleep(2);
for (my $i = 0; $i <= 20; $i++) {
  $window->scrollByLines(180);
  sleep(1);
}

## Get all tag a
my @fbids = $mech->xpath('//a');

## Prepare for read into a file
if ($exportUrlToFile == 1){
    open($fh, '>', 'url.txt') or die "Could not open file url.txt $!";
}

## Construct all http://graph.facebook.com/ url for each fbid and write it into a file
foreach my $fbid (@fbids){
    # if attribute id exists   
    if ($fbid->__attr('id') ne "")
    {
      my @id = $fbid->__attr('id')=~ m/(\d+)/g;
      if ($debug==1) {
          print "$id[0]\n";
      }
      my $graphurl = "http://graph.facebook.com/" . ($fbid->__attr('id')=~ m/(\d+)/g)[0] . "?fields=images";
      if ($debug==1) {
          print $graphurl . "\n";
      }

      ## Get graph.facebook.com JSON and parse it to get the biggest picture
      my $mechgraph = WWW::Mechanize::Firefox->new();
      $mechgraph->autoclose_tab( 1 );
      $mechgraph->get($graphurl);

      my $graphtext = $mechgraph->xpath('//pre', single => 1);
      if ($debug==1) {
          print $graphtext->{innerHTML} . "\n";
      }

      ## Parse JSON result
      my $json = new JSON;
      my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($graphtext->{innerHTML});
      if ($debug==1) {
          print @{$json_text->{images}}[0]->{source} . "\n";
      }

      if ($exportUrlToFile == 1){
          print $fh @{$json_text->{images}}[0]->{source} . "\n";
      }
      else {
          my $imageurl = @{$json_text->{images}}[0]->{source};

          my $filename = $imageurl;
          $filename =~ m/.*\/(.*)$/;
          $filename = $1;

          eval { mkpath($facebookAccountToGet) };
          if ($@) {
            print "Couldn't create $facebookAccountToGet: $@";
          }

          $mech->save_url($imageurl,"$facebookAccountToGet/$filename");
      }
      $count += 1;
    }
}

print "$count photos exported!\n";

if ($exportUrlToFile == 1){
    close $fh;
}