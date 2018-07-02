# File Date Match

Have you moved or copied photos to a new location on your phone or edited images and now they don't appear in the correct chronological order any more? Dude, are you in luck!

This poorly named script can help you out. It reads and interprets the filenames of file(s) you give it, and it will set the creation time to match the filename's date.

Usually, modern cameras will create file names with the shooting date built right in, like `20171225_105307_HDR.jpg` or `IMG_20150620_114109.jpg`. This gives us a solid starting point to work from if some other tool has gone and messed up the dates of your image collection or camera folder.

## Usage
Just run this script and give it the file, folder, or folders paths as arguments and it will do the rest in a moment. There's a convenient `--dry-run` option if you just want to test it out and verify what will happen. I like to specify this option first, before running the real thing.

```bash
perl file-date-fix.pl --dry-run /Volumes/SDCard/Pictures/AccessoryCamera/
```

and for real:

```bash
perl file-date-fix.pl /Volumes/SDCard/Pictures/AccessoryCamera/
```

You'll even get a little report when you're finished:

```
20180408_172052.mp4                Time: Mon, 09 Apr 2018 00:20:52 GMT
20180408_171202.mp4                Time: Mon, 09 Apr 2018 00:12:02 GMT
20180408_171006.mp4                Time: Mon, 09 Apr 2018 00:10:06 GMT
20180408_165238.mp4                Time: Sun, 08 Apr 2018 23:52:38 GMT
20180408_163403.mp4                Time: Sun, 08 Apr 2018 23:34:03 GMT
427 total files, 427 files updated, 0 skipped.
```
*You may notice that the times above don't match. This is due to the conversion and representation in GMT. Your local time-zone is calculated and factored into the conversion, so you can take photos anywhere in the world and it will still report the correct absolute-time.*

## Special considerations
macOS Finder really *loves* caching metadata, so if you don't see the new times reflected in the Finder after running this, and want to verify everything worked out as expected, you look at the actual modification time using the Terminal.app. Use the `-lT` switch in the `ls` command when pointed at the folder you're interested in to get a list with spelled-out dates included.

*Example:*

```bash
$ l -hT /Volumes/SDCard/Pictures/GooglePhotos-SD/
total 6144
-rwxrwxrwx  1 blake  staff   318K Sep 19 18:54:51 2016 20160919_185451-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   291K Sep 19 18:56:12 2016 20160919_185612-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   202K Sep 19 20:57:14 2016 20160919_205714-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   198K Sep 21 22:32:16 2016 20160921_223216-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   278K Sep 21 22:52:55 2016 20160921_225255-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   249K Oct 14 22:54:54 2016 20161014_225454-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   176K Oct 14 22:55:40 2016 20161014_225540-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   314K Oct 15 21:22:17 2016 20161015_212217-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   163K Oct 31 09:50:20 2016 20161031_095020-COLLAGE.jpg
-rwxrwxrwx  1 blake  staff   187K Oct 31 09:57:42 2016 20161031_095742-COLLAGE.jpg
```
