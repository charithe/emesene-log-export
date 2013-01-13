Emesene Chat Logs to HTML
=========================

This is a script to export an [Emesene](http://blog.emesene.org/) chat log into a HTML file. The Logger plugin for Emesene uses an SQLite database to store the chat history - which is difficult to navigate through. This script simply exports the conversation to a more readable HTML format.

N.B: This script was written in 2008 and hasn't been updated since. I am just sharing it here because even after five years, somebody on the internet found it to be quite useful.(See comment on my blog post at http://www.lucidelectricdreams.com/2008/12/dumping-emesene-chat-logs-to-html.html). 

Usage
-----

Install the DBD::SQLite package from CPAN.

```
sudo cpan -i DBD::SQLite
```


Find the Database where your logs are stored. This is usually in `$HOME/.config/emesene1.0/me_hotmail_com/cache/me@hotmail.com.db` where me@hotmail.com is your WLM email address.
```
./emlog.pl ~/.config/emesene1.0/me_hotmail_com/cache/me\@hotmail.com.db other_persons_username my_chats_wth_other_person.html
```


