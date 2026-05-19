# Analysis: dredmorbius

**Question:** Extract books, blogs, articles, podcasts, talks, papers, tools or other resources that this user has recommended (or strongly endorsed) in their comments. Group by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Tools, Other. Output clean GitHub-flavored markdown. Skip duplicates.

---

● List directory .
  └ 8 files found

● List directory users
  └ 7 files found

● Read hn-comments
  └ 104 lines read

● Read README.md
  └ 36 lines read

● List directory scripts

● Read justfile
  └ 38 lines read

● Search (glob)
  │ "users/**/comments.txt"
  └ 6 files found

● Search (glob)
  │ "users/**/recommendations.md"
  └ 6 files found

All 6 users already have both `comments.txt` and `recommendations.md`. But the user's question says "this user" — they likely want me to run the analysis. Let me check if there's a specific user context or if they want all of them. Let me also check git status for any pending work.

● Check recent git history (shell)
  │ cd /home/vlgk/github/hn-comments && git --no-pager log --oneline -10
  └ 11 lines...

● Check git status (shell)
  │ cd /home/vlgk/github/hn-comments && git --no-pager status --short
  └ 3 lines...

● Check comments file size (shell)
  │ wc -l /home/vlgk/github/hn-comments/users/dredmorbius/comments.txt
  └ 2 lines...

● Check recommendations file size (shell)
  │ wc -l /home/vlgk/github/hn-comments/users/dredmorbius/recommendations.md
  └ 2 lines...

● Read recommendations.md
  │ users/dredmorbius/recommendations.md
  └ 48 lines read

● General-purpose Extract recommended resources
  └ Agent started in background with agent_id: extract-books. You'll be noti...

Analyzing dredmorbius's 353K lines of HN comments to extract recommended resources. This will take a few minutes — waiting for the analysis agent to complete.

<system_notification>Background agent extract-books completed.</system_notification>

● Read (General-purpose agent — Extract recommended resources)
  └ Running

Still working on it — processing a very large file. Will continue once done.

<system_notification>Background agent extract-books completed.</system_notification>

● Read (General-purpose agent — Extract recommended resources)
  └ Running

Still processing — this is a very large comment history. Waiting for completion.

<system_notification>Background agent extract-books completed.</system_notification>

● Read (General-purpose agent — Extract recommended resources)
  └ Running

The agent is still processing the large file. Let me wait for it to complete.

<system_notification>Background agent extract-books completed.</system_notification>

● Read (General-purpose agent — Extract recommended resources)
  └ Running

The background agent appears stuck. Let me take over and do this directly.

● Search for recommendation keywords (shell)
  │ cd /home/vlgk/github/hn-comments && grep -n -i -E
  │ "(recommend|must.read|great book|excellent book|worth reading|I
  │ suggest|check out|highly recommend|favorite book|best book)"
  │ users/dredmorbius/comments.txt | head -200
  └ 7 lines...

● Filter book recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(recommend|must.read|great
  │ book|excellent book|worth reading|highly recommend|favorite book|best book)"
  │ users/dredmorbius/comments.txt | grep -i -E "(book|read)" | head -80
  └ 7 lines...

● Read book recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && cat
  │ /tmp/copilot-tool-output-1779196925334-zpq0z3.txt
  └ 7 lines...

● Read full book recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && head -c 26000
  │ /tmp/copilot-tool-output-1779196925334-zpq0z3.txt
  └ 7 lines...

● Read copilot-tool-output-1779196925334-zpq0z3.txt
  │ /tmp/copilot-tool-output-1779196925334-zpq0z3.txt
  └ 81 lines read

● Search blog/podcast/article recs (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E
  │ "(blog|podcast|article|paper|essay)" users/dredmorbius/comments.txt | grep
  │ -i -E "(recommend|excellent|great|worth|suggest|check out|strongly|must)" |
  │ head -60
  └ 7 lines...

● Read copilot-tool-output-1779196948021-sqd9re.txt
  │ /tmp/copilot-tool-output-1779196948021-sqd9re.txt
  └ 60 lines read

● Search tool recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(tool|software|app|utility)"
  │ users/dredmorbius/comments.txt | grep -i -E "(recommend|excellent|great|sugg
  │ est|strongly|must|love|fantastic|invaluable)" | head -30
  └ 31 lines...

● Search specific tool recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E
  │ "ublock|termux|signal|f-droid|einkbro|onyx boox|mpv|firefox|newsblur|feedly|
  │ pocket|calibre|koreader|syncthing|wireguard" users/dredmorbius/comments.txt
  │ | grep -i -E "(recommend|excellent|great|suggest|strongly|love|use|prefer)"
  │ | head -20
  └ 21 lines...

● Search specific author recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(vaclav
  │ smil|polanyi|yergin|adler|runciman|mackay|ophuls|homer-dixon|cathy
  │ o.neil|zerubavel|epstein|holt|beniger|shapiro|stern|lou schuler|needham)"
  │ users/dredmorbius/comments.txt | grep -i -E "(recommend|excellent|great|wort
  │ h|strongly|must|phenomenal|brilliant|masterful)" | head -30
  └ 31 lines...

● Search energy book recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(david mackay|sustainable
  │ energy|without the hot air|tom murphy|limits to growth|meadows)"
  │ users/dredmorbius/comments.txt | grep -i -E
  │ "(recommend|excellent|great|worth|resource|strongly)" | head -10
  └ 11 lines...

● Search more specific book recs (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(unix power
  │ tools|o.reilly|mander|studs terkel|baran|paul baran|burning
  │ buried|dukes|shane phillips|affordable
  │ city|catton|overshoot|heinberg|tainter|collapse of complex)"
  │ users/dredmorbius/comments.txt | grep -i -E …
  └ 18 lines...

● Search Mander book details (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(four arguments|jerry
  │ mander|television)" users/dredmorbius/comments.txt | grep -i -E
  │ "(recommend|worth|strongly|excellent|great|mander)" | head -10
  └ 11 lines...

Now I have enough data. Let me compile the final recommendations markdown.

● Search podcast recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(new books
  │ network|complexity podcast|santa fe|intelligence squared|past present
  │ future|fresh air|tiny spark|divided dial|on the media|ezra klein)"
  │ users/dredmorbius/comments.txt | grep -i -E
  │ "(recommend|excellent|great|worth|strongly|gem|listen)" | head -15
  └ 16 lines...

● Search library/archive recommendations (shell)
  │ cd /home/vlgk/github/hn-comments && grep -i -E "(librivox|project
  │ gutenberg|internet archive|archive\.org|open library|library
  │ genesis|libgen)" users/dredmorbius/comments.txt | grep -i -E
  │ "(recommend|excellent|great|gem|treasure|invaluable|wonderful|phenomenal)" |
  │ head -10
  └ 11 lines...

Now I have comprehensive data. Let me write the output.

## Books

- **Daniel Yergin — *The Prize* (1990)** — History of the oil industry. "I cannot recommend highly enough"; "really phenomenal"; "a brilliant work"; "unreservedly recommend this book as a masterful history."
- **Vaclav Smil — *Energy and Civilization* (2017)** — Human history through the lens of energy. "I'd suggest starting with Energy and Civilization."
- **Vaclav Smil — *Energy in World History* (1992, 2019)** — Particularly recommended alongside *Energy Transitions* (2016).
- **William Ophuls — *Ecology and the Politics of Scarcity* (1977)** — "Perhaps the best, most comprehensive, shortest, and most readable exposition" of limits to growth. Recommended repeatedly and without reservation.
- **William Ophuls — *Plato's Revenge* (2009/2011)** — Framework of political solutions to ecological limits.
- **Karl Polanyi — *The Great Transformation*** — "I'd strongly recommend Polanyi's The Great Transformation."
- **Mortimer J. Adler — *How to Read a Book*** — "I'd strongly recommend reading it"; "an excellent guide to reading."
- **David MacKay — *Sustainable Energy — Without the Hot Air*** — "Really is remarkable, and I highly recommend it to anyone with an interest in energy."
- **Shane Phillips — *The Affordable City*** — "I strongly recommend reading Shane Phillips, The Affordable City."
- **Cathy O'Neil — *Weapons of Math Destruction*** — Referenced approvingly for its treatment of data-based discrimination.
- **Jerry Mander — *Four Arguments for the Elimination of Television* (1978)** — "Mander is strongly recommended reading."
- **Hamilton Holt — *Commercialism and Journalism* (1909)** — "Short, information-dense, highly readable"; recommended "numerous times."
- **Edward Jay Epstein — *News from Nowhere*** — "A great book detailing" the production of television news.
- **Andrew L. Shapiro — *The Control Revolution* (1999)** — "Exceedingly prescient"; "I'd also very strongly recommend."
- **James Beniger — *The Control Revolution* (1986)** — "Excellent book"; "well worth reading."
- **Robert J. Gordon — *The Rise and Fall of American Growth*** — Highlighted as part of Princeton's "absolutely phenomenal" Economic History series.
- **William R. Catton — *Overshoot*** — "Looks at the ecological dynamics in more depth, with much wisdom."
- **Donella Meadows et al. — *The Limits to Growth* (1972)** — "Remains relevant"; "I strongly recommend reading primary sources."
- **Lou Schuler — *New Rules of Lifting* series** — "Amongst the reasons I strongly recommend it"; good for beginners with ramp to further knowledge.
- **Eviatar Zerubavel — *The Seven Day Circle*** — "A great book exploring the history of the Gregorian system."
- **Thomas Homer-Dixon — various works** — "I'd additionally strongly recommend the work of … Thomas Homer-Dixon."
- **Richard Heinberg — various works** — "Cover the ground of limits fairly accessibly and more recently."
- **Charles Perrow — *Normal Accidents* and *The Next Catastrophe*** — Explores organisational foundations of failure.
- **O'Reilly — *UNIX Power Tools*** — "I'd strongly recommend"; "one of the best 'what are some really useful recipes' books about Unix/Linux."
- **Bernhard J. Stern — *Resistances to the Adoption of Technological Innovations* (1937)** — "A great exploration of the general trend of established enterprises to oppose new arrivals."

## Blogs & Websites

- **ExRx.net** ([exrx.net](https://exrx.net/)) — "Large library of fitness information", including journals and expert talks.
- **Studs Terkel Archive** ([studsterkel.wfmt.com](https://studsterkel.wfmt.com/)) — "An absolute gem"; "a true gem and recommended for those who enjoy podcasts." 45 years of interviews.
- **Fresh Air Archive** ([freshairarchive.org](https://freshairarchive.org/)) — "Excellent archive site."
- **Explain XKCD** ([explainxkcd.com](https://explainxkcd.com/)) — "The Explain is worth reading."
- **Donella Meadows Project** ([donellameadows.org](https://donellameadows.org/)) — Hosts freely-available *Limits to Growth*.

## Articles / Posts / Papers

- **Jeffrey S. Dukes — "Burning Buried Sunshine" (2003)** — "An excellent paper" on how much biomass goes into fossil fuels.
- **Michael Schulson — "How to choose? If you can't choose wisely, choose randomly" (Aeon, 2014)** — "Classic and excellent" essay on sortition.
- **Paul Baran — writings on computerised data (1960s, RAND)** — "Recommended reading"; foundational work on data privacy concerns.
- **Hamilton Holt — *Commercialism and Journalism* (1909)** — Also functions as an article-length read (124 pages). "Strongly urge you to take it in."
- **Raphael Jolivet — essay on groups in Mastodon** ([raphael-jolivet.name](https://raphael-jolivet.name/en/blog/groups-in-mastodon-and-.../)) — "Recommend reading it."

## Podcasts / Talks

- **David Runciman — *Past Present Future*** (formerly *Talking Politics*, *History of Ideas*) — "Truly excellent"; "unreserved recommendation." Covers politics, philosophy, and history.
- **Complexity Podcast (Santa Fe Institute)** — "Highly recommended." Better under former host Michael Garfield.
- **Fresh Air (NPR) — Terry Gross & Dave Davies** — "Consummate interviewers, the guest list is excellent."
- **On the Media (WNYC Studios)** — Media analysis; praised the "Divided Dial" series on radio as "great."
- **Tiny Spark** — "Discontinued but has an excellent back-catalogue" on problems with philanthropy and charities.
- **Ezra Klein Show** — Principle exception to avoiding news-focused podcasts; book recommendations list noted.
- **New Books Network** ([newbooksnetwork.com](https://newbooksnetwork.com/)) — "Excellent"; "an excellent guide to what's coming out of academic presses."
- **Peter Adamson — *History of Philosophy Without Any Gaps*** — Among "faves."
- **Stephen West — *Philosophize This*** — Among "faves."
- **Nigel Warburton & David Edmonds — *Philosophy Bites* et al.** — Listed among quality philosophy podcasts.
- **Intelligence Squared** — "The New Optimism" debate noted as "worth listening to on its own."
- **LSE (London School of Economics) lecture series** — "Excellent lecture series."
- **Librivox short-story collections** — "Selected Shorts", "1001 Classic Short Stories and Tales" recommended for fiction listening.
- **Deutschlandfunk (German public radio)** — "Particularly fond of German radio's programming."
- **Ralph Nader interview by Studs Terkel (1967)** — "I cannot recommend this highly enough."

## Tools / Software

- **Onyx BOOX e-readers** (esp. Max Lumi 13.3") — "I strongly recommend the form-factor"; personal daily driver for 4+ years.
- **EinkBro** — "For web browsing, I recommend EinkBro" with paginated navigation for e-ink.
- **Termux** — Endorsed for Linux userland on Android; used extensively for technical work.
- **F-Droid** — "VERY strongly recommended" alternative Android app store.
- **uBlock Origin** — Recommended for ad/element blocking; element remover praised.
- **AntennaPod** — "My preferred app" for podcasts on Android.
- **Podcast Republic** — "Excellent podcast search capability" including episode/shownote indexing.
- **mpv** — Used for playing media/YouTube from command line; recommended with yt-dlp.
- **Signal** — Endorsed as "much better" than SMS for secure communications.
- **Fennic Fox (F-Droid Firefox)** — Installed for browser extensions, though inferior on e-ink to EinkBro.

## Other

- **Princeton University Press — "Economic History of the Western World" series** (ed. Joel Mokyr) — "An absolutely phenomenal treasury of books about economic history." 50+ titles.
- **Worldwatch Institute — *State of the World* annuals (1984–2017)** — "Give an excellent sense of the breadth and progress of thinking on sustainability." Available via Internet Archive.
- **PBS companion series to *The Prize* (1992)** — Recommended alongside Yergin's book.
- **Bertrand Russell — *History of Western Philosophy*** — Listed as "engaging" philosophical reading.
- **Will Durant — *Story of Philosophy*** — Also listed as engaging.
- **Project Gutenberg & Internet Archive** — Endorsed as lawful access to "a tremendous set of titles."
- **Kovarik — YouTube videos on communications history** — "I'd recommend for anyone interested in communications and its role on society."

