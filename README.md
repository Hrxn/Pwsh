## Hrxn/pwsh

I decided to put some of my scripts on here..

Please be aware:  
This is still a work-in-progress.  
Some of these were used in learning PowerShell in the first place.  
All usual disclaimers apply etc. pp.

##### A couple of notes:

Almost all of these are based on old Windows CMD scripts, sometimes also simply known as Batchfiles.

Rewriting my stuff in PowerShell seemed like a sane choice in order to make this all portable and ensure it's future proof, at least somewhat.

I strive to be somewhat consistent here in script design and language utilization (type accelerator capitalization - hello?!), but that is not an absolute priority.
All of these scripts are designed to be self-contained, i.e. they do not depend on each other, or on other PowerShell Modules, or Components etc.  
The one glaring exception is obviously scripts that are made to run other applications, like FFmpeg for example.
But I've started to add dependency checks in such cases. God knows who might need them..   
Please note that I'm targeting only fairly recent versions of PowerShell now. In other words, PowerShell Core only, or better. Version 7.2 is considered LTS, so that will be used as reference in the future.

#### Goals:
- Make terminal life easier and more joyful.
- Cross-platform usage.  
  To the extent that it's even possible at all. Some limitations still apply, obviously.  
  All platforms that are not Windows should be considered untested so far.
- Scratching my own itch.  
  The reason this came into existence.
- Moving to Markdown based external help someday (PlatyPS).
- No trailing whitespace. Ever.

#### Non-Goals:
- Replicating functionality that already exists within the shell (poof, so many old scripts not needed anymore).
- Competing with already established solutions or applications that already fit their purpose very well and solve their tasks.
- GUI usage, even in the distant future, although possible with PowerShell.
- Ugly optimizations and performance hacks.
- Excessive hand-holding.  
  I'm serious, do not expect to be spoonfed here. I'm trying to make these easily usable, but there is a line.  
  If you don't know how to use CLI programs, or how to properly set up your environment variables, you are wrong here.
