# Automation Scripts
These are a few automation scripts that I have built.

how to run them. 
On my server laptop. I set it up to not sleep ever when the screen is closed.

Then add the the automated scripts into the crontab
`sudo vim /etc/crontab`

Add a line with the following format

`# m h dom mon dow user command`

`minute` `hour` `day of month` `month` `day of week` `user` `command`

here is an example
```
0 6,18 * * * jacob python3 /home/jacob/Documents/fishstuff/scrape_fish_data.py
```
this will run at minute 0 of 6 AM and 6 PM every day of month
