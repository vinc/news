# Plain Text News

Fetch yesterday's news from Wikipedia current events portal
and summarize it with OpenAI.

## Setup

```
$ cp .news.env.sample ~/.news.env
$ bundle install
```

## Usage

```
$ bundle exec ruby news.rb
On Sunday, November 3, 2024, several armed conflicts and attacks were
reported across the globe. In the ongoing Israel-Hamas war, Israeli
airstrikes in Jabalia, northern Gaza, resulted in the deaths of more
than 50 children over two days, with at least 31 people killed across
the Gaza Strip, primarily in the north. Meanwhile, in the Russian
invasion of Ukraine, Russian forces captured the settlement of Vyshneve
in Donetsk Oblast, marking an advancement towards Hryhorivka. The
Israel-Hezbollah conflict escalated with Israeli airstrikes in
Lebanon's Beqaa Valley and Sidon, killing dozens and injuring several
others. In South Asia, a grenade explosion in a Srinagar market injured
eleven, while Naxalite insurgents in Chhattisgarh, India, injured two
police officers. In Somalia, Al-Shabaab's mortar attack on the Halane
base camp in Mogadishu resulted in three deaths and several injuries.

The day also witnessed several disasters and accidents. In Uganda, a
lightning strike at the Palabek Refugee Settlement killed 14 and
injured 34 others. In Ecuador, a truck accident in Morona-Santiago
Province led to ten fatalities, leaving a 3-year-old girl as the sole
survivor. Lahore, Pakistan, faced severe air pollution with an AQI
score of 1,073, prompting the Punjab government to close primary
schools for a week. In the political arena, incumbent President Maia
Sandu of Moldova won reelection amid allegations of Russian
interference. Protests erupted in Serbia over state negligence
following a deadly railway station canopy collapse, and in Spain,
political leaders faced protests during their visit to flood-hit
Valencia.

In sports, the Yokohama DeNA BayStars clinched the 2024 Japan Series
title by defeating the Fukuoka SoftBank Hawks in six games, securing
their third championship and first since 1998. This accomplishment
highlighted a day otherwise marked by violence, disaster, and political
unrest.
```

TODO: Update this example on a better day

## License

Released under MIT
