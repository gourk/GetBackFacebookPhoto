
Get back Facebook photo
================================

Introduction
-------------------------
GetBackFacebookPhoto is a perl script which download or help you to download all photos in high res of a public facebook account or an account you can access you.

This code is released under GPL license.

Installation
-------------------------
You must install perl and perl module WWW::Mechanize::Firefox, JSON and File::Path
You can install each module by cpan, like that cpan WWW:Mechanize::Firefox

You must install Firefox and the Plugin MozRepl --> https://addons.mozilla.org/en-us/firefox/addon/mozrepl/

How it works
-------------------------
1. Read the page Photostream https://www.facebook.com/xxxxxx/photos_stream
2. Get FBID of each picture
3. Read the page http://graph.facebook.com/659903270000000?fields=images
	where 659903270000000 is the FBID get back before
4. Get the direct to the high res picture
5. You can write all link into a text file and download it with command wget -i url.txt
   or you can download the picture directly

Help
-------------------------
Parameters to change
*Name or id of the account you want to extract photos
	my $facebookAccountToGet = "xxxxxxxxxxxx";
*Credential to connect on facebook if you need to connect to access the account
	my $facebookUser = '';
	my $facebookPwd = '';
*$exportUrlToFile if 1 export image url to url.txt else download image
	my $exportUrlToFile = 0;
*debug
	my $debug = 0;