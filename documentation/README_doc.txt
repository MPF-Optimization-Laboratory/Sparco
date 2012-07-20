How the Sparco Website Works
==========================
Clement Pajean, July 18 2012

Adapted from the Spot website generator created by Frances Russell, June 5 2012

>> JEMDOC PAGES

A few of the main pages are plain Jemdoc pages (see http://jemdoc.jaboc.net/index.html for Jemdoc syntax), including 'index', 'related links' and 'credits'. These can contain inserted raw html pages, like the 'sample_generate.html' inserted in generate.html, and also small blocks of raw html. After making any changes to the website files, run 'make' in the web directory. This uses jemdoc.py to make all the Jemdoc files into html files of the same name and update the menu.

>> STYLESHEET

The formatting for the website is defined by style.css, which is saved in the web directory. There are a few extra classes defined to help format the matlab-published examples and the index pages (see below) -- they are marked with comments. To change the look of the website, such as the font sizes, colours, or margins, you can edit this file and all the pages will change.

>> MENU

The MENU file defines what shows up on the menu bar of the website. At the top of each Jemdoc page, the 'menu{MENU}{filename.html}' line tells Jemdoc which link on the menu this file is.

>> MATLAB-PUBLISHED EXAMPLES

The example pages that contain executed code are made using the Matlab publish command. The .m files themselves are saved in the matlab_published/mfiles directory. There is a matlab script called publishsparcodoc.m in the web directory that turns these into webpages. To edit one of the Matlab examples or create a new one:

1. Save the .m file in matlab_published/mfiles

2. Open Matlab and run publishsparcodoc.m. It will ask you which of the files in the mfiles folder you want to publish - you should publish any files that you have just added or any that you have changed. Type 'y' to publish and 'n' to not publish for each file.

This is what publishsparcodoc.m does:
	- Publishes each .m file that you indicate, saving the resulting html files in matlab_published/html
	- Edits all of those html files so that they reference style.css and use the images in the correct folder
	- Generates a jemdoc page for each html file if it doesn't already exist, and puts an 'includeraw' line in to include the matlab-published html file (see guide_circulant2.jemdoc for an 	example).

3. If you have made a new page, add a line to MENU for your new html page (see above in 'MENU').

4. Run 'make' from the web directory.

>> MATLAB-PUBLISHED HELP (INDEX PAGES)

The 'problems' and 'tools' pages are generated using the Matlab help2html function, which creates html files directly from the documentation in the functions and classes. I've written two Matlab scripts, sparcoproblems.m and sparcotools.m, which use help2html to make a page with all the problems help (problems_list.html) and a page with all the tools help (tools_list.html), and edits them to reference style.css, puts an image in front of the problems and changes the links coming from "See also". These functions are in the web/htmlhelp folder. If you change the documentation in the Spot files, you can regenerate the index pages by running sparcoproblems.m or sparcotools.m.

As with the Matlab-published examples, these pages are wrapped in Jemdoc pages. 'problems.jemdoc' and 'tools.jemdoc' each have an 'includeraw' line that references htmlhelp/problems_list.html or htmlhelp/tools_list.html. They also each have a table of contents, written in raw html like for the guideto page (see above under 'Jemdoc pages'). When the sparcoproblems.m and sparcotools.m generate the pages, they insert the 'anchors' before each new method or operator so that the table of contents can link to them.

If you have added a new method or operator and want to update the index pages, you can simply run sparcoproblems.m or sparcotools.m, add a link to the table of contents in either problems.jemdoc or tools.jemdoc, then run 'make'.

>> IMAGES

To include an image in a regular Jemdoc page, you can use 'img_left' (see the Jemdoc website for details), but this is very limiting. The figures in guidetomethods are inserted using raw html -- just a simple table with images in the entries, so that you can also make captions. The image files for these kinds of pages are saved in the main web folder. They should be in .png format or something else that is compatible with html.

When you publish a Matlab file, all the figures it generates go into the web/matlab_published/html folder.
