{- | This plugin causes link URLs of the form wikiname!articlename to be
  treated as interwiki links.  So, for example,

> [The Emperor Palpatine](!Wookieepedia "Emperor Palpatine")

  links to the article on "Emperor Palpatine" in Wookieepedia
  (<http://starwars.wikia.com/wiki/Emperor_Palpatine>).

  This module also supports a shorter syntax, for when the link text
  is identical to the article name. Example:

> [Emperor Palpatine](!Wookieepedia)

  will link to the right place, same as the previous example.

  (Written by Gwern Branwen; put in public domain, 2009) -}

module InterwikiPlugin (plugin) where

import Gitit.Interface
import Gitit.Convert (refToUrl)

import qualified Data.Map as M (fromList, lookup, Map)
import Network.URI (escapeURIString, isAllowedInURI, unEscapeString)

plugin :: Plugin
plugin = PageTransform interwikiTransform

interwikiTransform :: AppState -> Pandoc -> Web Pandoc
interwikiTransform _ = return . processWith convertInterwikiLinks

{- | A good interwiki link looks like '!Wookieepedia "Emperor Palpatine"'. So we check for a leading '!'.
     We strip it off, and now we have the canonical sitename (in this case, "Wookieepedia" and we look it up
     in our database.
     The database should return the URL for that site; we only need append the (escaped) article name to that,
     and we have the full URL! If there isn't one there, then we look back at the link-text for the article
     name; this is how we support the shortened syntax (see module description).
     If there isn't a leading '!', we get back a Nothing (the database doesn't know the site), we just return
     the Link unchanged. -}
convertInterwikiLinks :: Inline -> Inline
convertInterwikiLinks (Link ref (interwiki, article)) =
  if head interwiki == '!'
     then case M.lookup interwiki' interwikiMap of
                Just url  -> case article of
                                  "" -> Link ref (url ++ (refToUrl ref), (summary $ unEscapeString $ refToUrl ref))
                                  _ -> Link ref (interwikiurl article url, summary article)
                Nothing -> Link ref (interwiki, article)
     else Link ref (interwiki, article)
 where -- '!Wookieepedia' -> 'Wookieepedia'
       interwiki' = tail interwiki
       -- 'http://starwars.wikia.com/wiki/Emperor_Palpatine'
       interwikiurl a u = escapeURIString isAllowedInURI $ u ++ a
       -- 'Wookieepedia: Emperor Palpatine'
       summary a = interwiki' ++ ": " ++ a
convertInterwikiLinks x = x

{- | Large table of constants; this is a mapping from shortcuts to a URL. The URL can be used by
   appending to it the article name (suitably URL-escaped, of course).
   The mapping is derived from <https://secure.wikimedia.org/wikipedia/meta/wiki/Interwiki_map>
   as of 11:19 PM, 11 February 2009. -}
interwikiMap :: M.Map String String
interwikiMap = M.fromList [ ("AbbeNormal", "http://ourpla.net/cgi/pikie?"),
                 ("Acronym", "http://www.acronymfinder.com/af-query.asp?String=exact&Acronym="),
                 ("Advisory", "http://advisory.wikimedia.org/wiki/"),
                 ("Advogato", "http://www.advogato.org/"),
                 ("Aew", "http://wiki.arabeyes.org/"),
                 ("Airwarfare", "http://airwarfare.com/mediawiki-1.4.5/index.php?"),
                 ("AIWiki", "http://www.ifi.unizh.ch/ailab/aiwiki/aiw.cgi?"),
                 ("AllWiki", "http://allwiki.com/index.php/"),
                 ("Appropedia", "http://www.appropedia.org/"),
                 ("AquariumWiki", "http://www.theaquariumwiki.com/"),
                 ("arXiv", "http://arxiv.org/abs/"),
                 ("AspieNetWiki", "http://aspie.mela.de/index.php/"),
                 ("AtmWiki", "http://www.otterstedt.de/wiki/index.php/"),
                 ("BattlestarWiki", "http://en.battlestarwiki.org/wiki/"),
                 ("BEMI", "http://bemi.free.fr/vikio/index.php?"),
                 ("BenefitsWiki", "http://www.benefitslink.com/cgi-bin/wiki.cgi?"),
                 ("betawiki", "http://translatewiki.net/wiki/"),
                 ("BibleWiki", "http://bible.tmtm.com/wiki/"),
                 ("BluWiki", "http://www.bluwiki.org/go/"),
                 ("Botwiki", "http://botwiki.sno.cc/wiki/"),
                 ("Boxrec", "http://www.boxrec.com/media/index.php?"),
                 ("BrickWiki", "http://brickwiki.org/index.php?title="),
                 ("BridgesWiki", "http://c2.com:8000/"),
                 ("bugzilla", "https://bugzilla.wikimedia.org/show_bug.cgi?id="),
                 ("buzztard", "http://buzztard.org/index.php/"),
                 ("Bytesmiths", "http://www.Bytesmiths.com/wiki/"),
                 ("C2", "http://c2.com/cgi/wiki?"),
                 ("C2find", "http://c2.com/cgi/wiki?FindPage&value="),
                 ("Cache", "http://www.google.com/search?q=cache:"),
                 ("CanyonWiki", "http://www.canyonwiki.com/wiki/index.php/"),
                 ("CANWiki", "http://www.can-wiki.info/"),
                 ("ĈEJ", "http://esperanto.blahus.cz/cxej/vikio/index.php/"),
                 ("CellWiki", "http://cell.wikia.com/wiki/"),
                 ("CentralWikia", "http://www.wikia.com/wiki/"),
                 ("ChEJ", "http://esperanto.blahus.cz/cxej/vikio/index.php/"),
                 ("ChoralWiki", "http://www.cpdl.org/wiki/index.php/"),
                 ("Ciscavate", "http://ciscavate.org/index.php/"),
                 ("Citizendium", "http://en.citizendium.org/wiki/"),
                 ("CKWiss", "http://ck-wissen.de/ckwiki/index.php?title="),
                 ("CNDbName", "http://cndb.com/actor.html?name="),
                 ("CNDbTitle", "http://cndb.com/movie.html?title="),
                 ("CoLab", "http://colab.info"),
                 ("Comixpedia", "http://www.comixpedia.org/index.php/"),
                 ("comcom", "http://comcom.wikimedia.org/wiki/"),
                 ("Commons", "http://commons.wikimedia.org/wiki/"),
                 ("CommunityScheme", "http://community.schemewiki.org/?c=s&key="),
                 ("comune", "http://rete.comuni-italiani.it/wiki/"),
                 ("Consciousness", "http://teadvus.inspiral.org/index.php/"),
                 ("CorpKnowPedia", "http://corpknowpedia.org/wiki/index.php/"),
                 ("CrazyHacks", "http://www.crazy-hacks.org/wiki/index.php?title="),
                 ("CreaturesWiki", "http://creatures.wikia.com/wiki/"),
                 ("CxEJ", "http://esperanto.blahus.cz/cxej/vikio/index.php/"),
                 ("DAwiki", "http://www.dienstag-abend.de/wiki/index.php/"),
                 ("Dcc", "http://www.dccwiki.com/"),
                 ("DCDatabase", "http://www.dcdatabaseproject.com/wiki/"),
                 ("DCMA", "http://www.christian-morgenstern.de/dcma/"),
                 ("DejaNews", "http://www.deja.com/=dnc/getdoc.xp?AN="),
                 ("Delicious", "http://del.icio.us/tag/"),
                 ("Demokraatia", "http://wiki.demokraatia.ee/index.php/"),
                 ("Devmo", "http://developer.mozilla.org/en/docs/"),
                 ("Dictionary", "http://www.dict.org/bin/Dict?Database=*&Form=Dict1&Strategy=*&Query="),
                 ("Dict", "http://www.dict.org/bin/Dict?Database=*&Form=Dict1&Strategy=*&Query="),
                 ("Disinfopedia", "http://www.sourcewatch.org/wiki.phtml?title="),
                 ("distributedproofreaders", "http://www.pgdp.net/wiki/"),
                 ("distributedproofreadersca", "http://www.pgdpcanada.net/wiki/index.php/"),
                 ("dmoz", "http://www.dmoz.org/"),
                 ("dmozs", "http://www.dmoz.org/cgi-bin/search?search="),
                 ("DocBook", "http://wiki.docbook.org/topic/"),
                 ("DOI", "http://dx.doi.org/"),
                 ("doom_wiki", "http://doom.wikia.com/wiki/"),
                 ("download", "http://download.wikimedia.org/"),
                 ("dbdump", "http://download.wikimedia.org//latest/"),
                 ("DRAE", "http://buscon.rae.es/draeI/SrvltGUIBusUsual?LEMA="),
                 ("Dreamhost", "http://wiki.dreamhost.com/index.php/"),
                 ("DrumCorpsWiki", "http://www.drumcorpswiki.com/index.php/"),
                 ("DWJWiki", "http://www.suberic.net/cgi-bin/dwj/wiki.cgi?"),
                 ("EĉeI", "http://www.ikso.net/cgi-bin/wiki.pl?"),
                 ("EcheI", "http://www.ikso.net/cgi-bin/wiki.pl?"),
                 ("EcoReality", "http://www.EcoReality.org/wiki/"),
                 ("EcxeI", "http://www.ikso.net/cgi-bin/wiki.pl?"),
                 ("EfnetCeeWiki", "http://purl.net/wiki/c/"),
                 ("EfnetCppWiki", "http://purl.net/wiki/cpp/"),
                 ("EfnetPythonWiki", "http://purl.net/wiki/python/"),
                 ("EfnetXmlWiki", "http://purl.net/wiki/xml/"),
                 ("ELibre", "http://enciclopedia.us.es/index.php/"),
                 ("EmacsWiki", "http://www.emacswiki.org/cgi-bin/wiki.pl?"),
                 ("EnergieWiki", "http://www.netzwerk-energieberater.de/wiki/index.php/"),
                 ("EoKulturCentro", "http://esperanto.toulouse.free.fr/nova/wikini/wakka.php?wiki="),
                 ("Ethnologue", "http://www.ethnologue.com/show_language.asp?code="),
                 ("EvoWiki", "http://wiki.cotch.net/index.php/"),
                 ("Exotica", "http://www.exotica.org.uk/wiki/"),
                 ("FanimutationWiki", "http://wiki.animutationportal.com/index.php/"),
                 ("FinalEmpire", "http://final-empire.sourceforge.net/cgi-bin/wiki.pl?"),
                 ("FinalFantasy", "http://finalfantasy.wikia.com/wiki/"),
                 ("Finnix", "http://www.finnix.org/"),
                 ("FlickrUser", "http://www.flickr.com/people/"),
                 ("FloralWIKI", "http://www.floralwiki.co.uk/wiki/"),
                 ("FlyerWiki-de", "http://de.flyerwiki.net/index.php/"),
                 ("Foldoc", "http://www.foldoc.org/"),
                 ("ForthFreak", "http://wiki.forthfreak.net/index.cgi?"),
                 ("Foundation", "http://wikimediafoundation.org/wiki/"),
                 ("FoxWiki", "http://fox.wikis.com/wc.dll?Wiki~"),
                 ("FreeBio", "http://freebiology.org/wiki/"),
                 ("FreeBSDman", "http://www.FreeBSD.org/cgi/man.cgi?apropos=1&query="),
                 ("FreeCultureWiki", "http://wiki.freeculture.org/index.php/"),
                 ("Freedomdefined", "http://freedomdefined.org/"),
                 ("FreeFeel", "http://freefeel.org/wiki/"),
                 ("FreekiWiki", "http://wiki.freegeek.org/index.php/"),
                 ("Freenode", "http://ganfyd.org/index.php?title="),
                 ("GaussWiki", "http://gauss.ffii.org/"),
                 ("Gentoo-Wiki", "http://gentoo-wiki.com/"),
                 ("GenWiki", "http://wiki.genealogy.net/index.php/"),
                 ("GlobalVoices", "http://cyber.law.harvard.edu/dyn/globalvoices/wiki/"),
                 ("GlossarWiki", "http://glossar.hs-augsburg.de/"),
                 ("GlossaryWiki", "http://glossary.hs-augsburg.de/"),
                 ("Golem", "http://golem.linux.it/index.php/"),
                 ("Google", "http://www.google.com/search?q="),
                 ("GoogleDefine", "http://www.google.com/search?q=define:"),
                 ("GoogleGroups", "http://groups.google.com/groups?q="),
                 ("GotAMac", "http://www.got-a-mac.org/"),
                 ("GreatLakesWiki", "http://greatlakeswiki.org/index.php/"),
                 ("Guildwiki", "http://gw.gamewikis.org/wiki/"),
                 ("gutenberg", "http://www.gutenberg.org/etext/"),
                 ("gutenbergwiki", "http://www.gutenberg.org/wiki/"),
                 ("H2Wiki", "http://halowiki.net/p/"),
                 ("HammondWiki", "http://www.dairiki.org/HammondWiki/index.php3?"),
                 ("heroeswiki", "http://heroeswiki.com/"),
                 ("HerzKinderWiki", "http://www.herzkinderinfo.de/Mediawiki/index.php/"),
                 ("HKMule", "http://www.hkmule.com/wiki/"),
                 ("HolshamTraders", "http://www.holsham-traders.de/wiki/index.php/"),
                 ("HRWiki", "http://www.hrwiki.org/index.php/"),
                 ("HRFWiki", "http://fanstuff.hrwiki.org/index.php/"),
                 ("HumanCell", "http://www.humancell.org/index.php/"),
                 ("HupWiki", "http://wiki.hup.hu/index.php/"),
                 ("IMDbName", "http://www.imdb.com/name/nm/"),
                 ("IMDbTitle", "http://www.imdb.com/title/tt/"),
                 ("IMDbCompany", "http://www.imdb.com/company/co/"),
                 ("IMDbCharacter", "http://www.imdb.com/character/ch/"),
                 ("Incubator", "http://incubator.wikimedia.org/wiki/"),
                 ("infoAnarchy", "http://www.infoanarchy.org/en/"),
                 ("Infosecpedia", "http://www.infosecpedia.org/pedia/index.php/"),
                 ("Infosphere", "http://theinfosphere.org/"),
                 ("IRC", "http://www.sil.org/iso639-3/documentation.asp?id="),
                 ("Iuridictum", "http://iuridictum.pecina.cz/w/"),
                 ("JamesHoward", "http://jameshoward.us/"),
                 ("JavaNet", "http://wiki.java.net/bin/view/Main/"),
                 ("Javapedia", "http://wiki.java.net/bin/view/Javapedia/"),
                 ("JEFO", "http://esperanto-jeunes.org/wiki/"),
                 ("JiniWiki", "http://www.cdegroot.com/cgi-bin/jini?"),
                 ("JspWiki", "http://www.ecyrd.com/JSPWiki/Wiki.jsp?page="),
                 ("JSTOR", "http://www.jstor.org/journals/"),
                 ("Kamelo", "http://kamelopedia.mormo.org/index.php/"),
                 ("Karlsruhe", "http://ka.stadtwiki.net/"),
                 ("KerimWiki", "http://wiki.oxus.net/"),
                 ("KinoWiki", "http://kino.skripov.com/index.php/"),
                 ("KmWiki", "http://kmwiki.wikispaces.com/"),
                 ("KontuWiki", "http://kontu.merri.net/wiki/"),
                 ("KoslarWiki", "http://wiki.koslar.de/index.php/"),
                 ("Kpopwiki", "http://www.kpopwiki.com/"),
                 ("LinguistList", "http://linguistlist.org/forms/langs/LLDescription.cfm?code="),
                 ("LinuxWiki", "http://www.linuxwiki.de/"),
                 ("LinuxWikiDe", "http://www.linuxwiki.de/"),
                 ("LISWiki", "http://liswiki.org/wiki/"),
                 ("LiteratePrograms", "http://en.literateprograms.org/"),
                 ("Livepedia", "http://www.livepedia.gr/index.php?title="),
                 ("Lojban", "http://www.lojban.org/tiki/tiki-index.php?page="),
                 ("Lostpedia", "http://en.lostpedia.com/wiki/"),
                 ("LQWiki", "http://wiki.linuxquestions.org/wiki/"),
                 ("LugKR", "http://lug-kr.sourceforge.net/cgi-bin/lugwiki.pl?"),
                 ("Luxo", "http://toolserver.org/~luxo/contributions/contributions.php?user="),
                 ("lyricwiki", "http://www.lyricwiki.org/"),
                 ("Mail", "https://lists.wikimedia.org/mailman/listinfo/"),
                 ("mailarchive", "http://lists.wikimedia.org/pipermail/"),
                 ("Mariowiki", "http://www.mariowiki.com/"),
                 ("MarvelDatabase", "http://www.marveldatabase.com/wiki/index.php/"),
                 ("MeatBall", "http://www.usemod.com/cgi-bin/mb.pl?"),
                 ("MediaZilla", "https://bugzilla.wikimedia.org/"),
                 ("MemoryAlpha", "http://memory-alpha.org/en/wiki/"),
                 ("MetaWiki", "http://sunir.org/apps/meta.pl?"),
                 ("MetaWikiPedia", "http://meta.wikimedia.org/wiki/"),
                 ("Mineralienatlas", "http://www.mineralienatlas.de/lexikon/index.php/"),
                 ("MoinMoin", "http://moinmo.in/"),
                 ("Monstropedia", "http://www.monstropedia.org/?title="),
                 ("MosaPedia", "http://mosapedia.de/wiki/index.php/"),
                 ("MozCom", "http://mozilla.wikia.com/wiki/"),
                 ("MozillaWiki", "http://wiki.mozilla.org/"),
                 ("MozillaZineKB", "http://kb.mozillazine.org/"),
                 ("MusicBrainz", "http://wiki.musicbrainz.org/"),
                 ("MW", "http://www.mediawiki.org/wiki/"),
                 ("MWOD", "http://www.merriam-webster.com/cgi-bin/dictionary?book=Dictionary&va="),
                 ("MWOT", "http://www.merriam-webster.com/cgi-bin/thesaurus?book=Thesaurus&va="),
                 ("NetVillage", "http://www.netbros.com/?"),
                 ("NKcells", "http://www.nkcells.info/wiki/index.php/"),
                 ("NoSmoke", "http://no-smok.net/nsmk/"),
                 ("Nost", "http://nostalgia.wikipedia.org/wiki/"),
                 ("OEIS", "http://www.research.att.com/~njas/sequences/"),
                 ("OldWikisource", "http://wikisource.org/wiki/"),
                 ("OLPC", "http://wiki.laptop.org/go/"),
                 ("OneLook", "http://www.onelook.com/?ls=b&w="),
                 ("OpenFacts", "http://openfacts.berlios.de/index.phtml?title="),
                 ("Openstreetmap", "http://wiki.openstreetmap.org/index.php/"),
                 ("OpenWetWare", "http://openwetware.org/wiki/"),
                 ("OpenWiki", "http://openwiki.com/?"),
                 ("Opera7Wiki", "http://operawiki.info/"),
                 ("OrganicDesign", "http://www.organicdesign.co.nz/"),
                 ("OrgPatterns", "http://www.bell-labs.com/cgi-user/OrgPatterns/OrgPatterns?"),
                 ("OrthodoxWiki", "http://orthodoxwiki.org/"),
                 ("OSI", "http://wiki.tigma.ee/index.php/"),
                 ("OTRS", "https://secure.wikimedia.org/otrs/index.pl?Action=AgentTicketZoom&TicketID="),
                 ("OTRSwiki", "http://otrs-wiki.wikimedia.org/wiki/"),
                 ("OurMedia", "http://www.socialtext.net/ourmedia/index.cgi?"),
                 ("PaganWiki", "http://www.paganwiki.org/wiki/index.php?title="),
                 ("Panawiki", "http://wiki.alairelibre.net/wiki/"),
                 ("PangalacticOrg", "http://www.pangalactic.org/Wiki/"),
                 ("PatWIKI", "http://gauss.ffii.org/"),
                 ("PerlConfWiki", "http://perl.conf.hu/index.php/"),
                 ("PerlNet", "http://perl.net.au/wiki/"),
                 ("PersonalTelco", "http://www.personaltelco.net/index.cgi/"),
                 ("PHWiki", "http://wiki.pocketheaven.com/"),
                 ("PhpWiki", "http://phpwiki.sourceforge.net/phpwiki/index.php?"),
                 ("PlanetMath", "http://planetmath.org/?op=getobj&from=objects&id="),
                 ("PMEG", "http://www.bertilow.com/pmeg/.php"),
                 ("PMWiki", "http://old.porplemontage.com/wiki/index.php/"),
                 ("PurlNet", "http://purl.oclc.org/NET/"),
                 ("PythonInfo", "http://www.python.org/cgi-bin/moinmoin/"),
                 ("PythonWiki", "http://www.pythonwiki.de/"),
                 ("PyWiki", "http://c2.com/cgi/wiki?"),
                 ("psycle", "http://psycle.sourceforge.net/wiki/"),
                 ("qcwiki", "http://wiki.quantumchemistry.net/index.php/"),
                 ("Quality", "http://quality.wikimedia.org/wiki/"),
                 ("Qwiki", "http://qwiki.caltech.edu/wiki/"),
                 ("r3000", "http://prinsig.se/weekee/"),
                 ("RakWiki", "http://rakwiki.no-ip.info/"),
                 ("Raec", "http://www.raec.clacso.edu.ar:8080/raec/Members/raecpedia/"),
                 ("rev", "http://www.mediawiki.org/wiki/Special:Code/MediaWiki/"),
                 ("ReVo", "http://purl.org/NET/voko/revo/art/.html"),
                 ("RFC", "http://tools.ietf.org/html/rfc"),
                 ("RheinNeckar", "http://wiki.rhein-neckar.de/index.php/"),
                 ("RoboWiki", "http://robowiki.net/?"),
                 ("ReutersWiki", "http://glossary.reuters.com/index.php/"),
                 ("RoWiki", "http://wiki.rennkuckuck.de/index.php/"),
                 ("rtfm", "http://s23.org/wiki/"),
                 ("Scholar", "http://scholar.google.com/scholar?q="),
                 ("SchoolsWP", "http://schools-wikipedia.org/wiki/"),
                 ("Scores", "http://www.imslp.org/wiki/"),
                 ("Scoutwiki", "http://en.scoutwiki.org/"),
                 ("Scramble", "http://www.scramble.nl/wiki/index.php?title="),
                 ("SeaPig", "http://www.seapig.org/"),
                 ("SeattleWiki", "http://seattlewiki.org/wiki/"),
                 ("SeattleWireless", "http://seattlewireless.net/?"),
                 ("SLWiki", "http://wiki.secondlife.com/wiki/"),
                 ("SenseisLibrary", "http://senseis.xmp.net/?"),
                 ("silcode", "http://www.sil.org/iso639-3/documentation.asp?id="),
                 ("Shakti", "http://cgi.algonet.se/htbin/cgiwrap/pgd/ShaktiWiki/"),
                 ("Slashdot", "http://slashdot.org/article.pl?sid="),
                 ("SMikipedia", "http://www.smiki.de/"),
                 ("SourceForge", "http://sourceforge.net/"),
                 ("spcom", "http://spcom.wikimedia.org/wiki/"),
                 ("Species", "http://species.wikimedia.org/wiki/"),
                 ("Squeak", "http://wiki.squeak.org/squeak/"),
                 ("stable", "http://stable.toolserver.org/"),
                 ("StrategyWiki", "http://strategywiki.org/wiki/"),
                 ("Sulutil", "http://toolserver.org/~vvv/sulutil.php?user="),
                 ("Susning", "http://www.susning.nu/"),
                 ("Swtrain", "http://train.spottingworld.com/"),
                 ("svn", "http://svn.wikimedia.org/viewvc/mediawiki/?view=log"),
                 ("SVGWiki", "http://www.protocol7.com/svg-wiki/default.asp?"),
                 ("SwinBrain", "http://mercury.it.swin.edu.au/swinbrain/index.php/"),
                 ("SwingWiki", "http://www.swingwiki.org/"),
                 ("TabWiki", "http://www.tabwiki.com/index.php/"),
                 ("Takipedia", "http://www.takipedia.org/wiki/"),
                 ("Tavi", "http://tavi.sourceforge.net/"),
                 ("TclersWiki", "http://wiki.tcl.tk/"),
                 ("Technorati", "http://www.technorati.com/search/"),
                 ("TEJO", "http://www.tejo.org/vikio/"),
                 ("TESOLTaiwan", "http://www.tesol-taiwan.org/wiki/index.php/"),
                 ("Testwiki", "http://test.wikipedia.org/wiki/"),
                 ("Thelemapedia", "http://www.thelemapedia.org/index.php/"),
                 ("Theopedia", "http://www.theopedia.com/"),
                 ("ThePPN", "http://wiki.theppn.org/"),
                 ("ThinkWiki", "http://www.thinkwiki.org/wiki/"),
                 ("TibiaWiki", "http://tibia.erig.net/"),
                 ("Ticket", "https://secure.wikimedia.org/otrs/index.pl?Action=AgentTicketZoom&TicketNumber="),
                 ("TMBW", "http://tmbw.net/wiki/"),
                 ("TmNet", "http://www.technomanifestos.net/?"),
                 ("TMwiki", "http://www.EasyTopicMaps.com/?page="),
                 ("TokyoNights", "http://wiki.tokyo-nights.com/wiki/"),
                 ("Tools", "http://toolserver.org/"),
                 ("tswiki", "http://wiki.toolserver.org/view/"),
                 ("translatewiki", "http://translatewiki.net/wiki/"),
                 ("Trash!Italia", "http://trashware.linux.it/wiki/"),
                 ("Turismo", "http://www.tejo.org/turismo/"),
                 ("TVIV", "http://tviv.org/wiki/"),
                 ("TVtropes", "http://www.tvtropes.org/pmwiki/pmwiki.php/Main/"),
                 ("TWiki", "http://twiki.org/cgi-bin/view/"),
                 ("TwistedWiki", "http://purl.net/wiki/twisted/"),
                 ("TyvaWiki", "http://www.tyvawiki.org/wiki/"),
                 ("Uncyclopedia", "http://uncyclopedia.org/wiki/"),
                 ("Unreal", "http://wiki.beyondunreal.com/wiki/"),
                 ("Urbandict", "http://www.urbandictionary.com/define.php?term="),
                 ("USEJ", "http://www.tejo.org/usej/"),
                 ("UseMod", "http://www.usemod.com/cgi-bin/wiki.pl?"),
                 ("ValueWiki", "http://www.valuewiki.com/w/"),
                 ("Veropedia", "http://en.veropedia.com/a/"),
                 ("Vinismo", "http://vinismo.com/en/"),
                 ("VLOS", "http://www.thuvienkhoahoc.com/tusach/"),
                 ("VKoL", "http://kol.coldfront.net/thekolwiki/index.php/"),
                 ("VoIPinfo", "http://www.voip-info.org/wiki/view/"),
                 ("WarpedView", "http://www.warpedview.com/mediawiki/index.php/"),
                 ("WebDevWikiNL", "http://www.promo-it.nl/WebDevWiki/index.php?page="),
                 ("Webisodes", "http://www.webisodes.org/"),
                 ("WebSeitzWiki", "http://webseitz.fluxent.com/wiki/"),
                 ("wg", "http://wg.en.wikipedia.org/wiki/"),
                 ("Wiki", "http://c2.com/cgi/wiki?"),
                 ("Wikia", "http://www.wikia.com/wiki/c:"),
                 ("WikiaSite", "http://www.wikia.com/wiki/c:"),
                 ("Wikianso", "http://www.ansorena.de/mediawiki/wiki/"),
                 ("Wikible", "http://wikible.org/en/"),
                 ("Wikibooks", "http://en.wikibooks.org/wiki/"),
                 ("Wikichat", "http://www.wikichat.org/"),
                 ("WikiChristian", "http://www.wikichristian.org/index.php?title="),
                 ("Wikicities", "http://www.wikia.com/wiki/"),
                 ("Wikicity", "http://www.wikia.com/wiki/c:"),
                 ("WikiF1", "http://www.wikif1.org/"),
                 ("WikiFur", "http://en.wikifur.com/wiki/"),
                 ("wikiHow", "http://www.wikihow.com/"),
                 ("WikiIndex", "http://wikiindex.com/"),
                 ("WikiLemon", "http://wiki.illemonati.com/"),
                 ("Wikilivres", "http://wikilivres.info/wiki/"),
                 ("WikiMac-de", "http://apfelwiki.de/wiki/Main/"),
                 ("WikiMac-fr", "http://www.wikimac.org/index.php/"),
                 ("Wikimedia", "http://wikimediafoundation.org/wiki/"),
                 ("Wikinews", "http://en.wikinews.org/wiki/"),
                 ("Wikinfo", "http://www.wikinfo.org/index.php/"),
                 ("Wikinurse", "http://wikinurse.org/media/index.php?title="),
                 ("Wikinvest", "http://www.wikinvest.com/"),
                 ("Wikipaltz", "http://www.wikipaltz.com/wiki/"),
                 ("Wikipedia", "http://en.wikipedia.org/wiki/"),
                 ("WikipediaWikipedia", "http://en.wikipedia.org/wiki/Wikipedia:"),
                 ("Wikiquote", "http://en.wikiquote.org/wiki/"),
                 ("Wikireason", "http://wikireason.net/wiki/"),
                 ("Wikischool", "http://www.wikischool.de/wiki/"),
                 ("wikisophia", "http://wikisophia.org/index.php?title="),
                 ("Wikisource", "http://en.wikisource.org/wiki/"),
                 ("Wikispecies", "http://species.wikimedia.org/wiki/"),
                 ("Wikispot", "http://wikispot.org/?action=gotowikipage&v="),
                 ("WikiTI", "http://wikiti.denglend.net/index.php?title="),
                 ("WikiTravel", "http://wikitravel.org/en/"),
                 ("WikiTree", "http://wikitree.org/index.php?title="),
                 ("Wikiversity", "http://en.wikiversity.org/wiki/"),
                 ("betawikiversity", "http://beta.wikiversity.org/wiki/"),
                 ("WikiWikiWeb", "http://c2.com/cgi/wiki?"),
                 ("Wiktionary", "http://en.wiktionary.org/wiki/"),
                 ("Wipipedia", "http://www.londonfetishscene.com/wipi/index.php/"),
                 ("WLUG", "http://www.wlug.org.nz/"),
                 ("wmcz", "http://meta.wikimedia.org/wiki/Wikimedia_Czech_Republic/"),
                 ("Wm2005", "http://wikimania2005.wikimedia.org/wiki/"),
                 ("Wm2006", "http://wikimania2006.wikimedia.org/wiki/"),
                 ("Wm2007", "http://wikimania2007.wikimedia.org/wiki/"),
                 ("Wm2008", "http://wikimania2008.wikimedia.org/wiki/"),
                 ("Wm2009", "http://wikimania2009.wikimedia.org/wiki/"),
                 ("Wmania", "http://wikimania.wikimedia.org/wiki/"),
                 ("WMF", "http://wikimediafoundation.org/wiki/"),
                 ("wmse", "http://se.wikimedia.org/wiki/"),
                 ("wmrs", "http://rs.wikimedia.org/wiki/"),
                 ("Wookieepedia", "http://starwars.wikia.com/wiki/"),
                 ("World66", "http://www.world66.com/"),
                 ("WoWWiki", "http://www.wowwiki.com/"),
                 ("Wqy", "http://wqy.sourceforge.net/cgi-bin/index.cgi?"),
                 ("WurmPedia", "http://www.wurmonline.com/wiki/index.php/"),
                 ("WZNAN", "http://www.wikiznanie.ru/wiki/article/"),
                 ("Xboxic", "http://wiki.xboxic.com/"),
                 ("ZRHwiki", "http://www.zrhwiki.ch/wiki/"),
                 ("ZUM", "http://wiki.zum.de/"),
                 ("ZWiki", "http://www.zwiki.org/"),
                 ("ZZZ", "http://wiki.zzz.ee/index.php/") ]
