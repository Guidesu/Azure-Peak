/datum/species/human/northern
	desc_title = "Humans"
	desc = "Human is the common name for a race with a rather familiar appearance to everyone. It is very difficult (if not impossible) to find a place where the human race is unknown. In most countries of Grimoria, humans are the dominant race. Indeed: people of all skin colors and sub-races are far more numerous in the world than all others combined. Possessing ordinary reproductive capabilities, humans prevail largely because they are not only the largest race — causing their growth to occur in geometric progression — but also one of the oldest races — some believe this race descends from the Allfather himself, while others claim that Humans emerged if not later, then at the same time as the elves."
	languages = list(/datum/language/common)

/datum/species/tieberian
	desc_title = "Tieflings"
	desc = "The first tieflings appeared in the Inferno, as a product of interbreeding between representatives of mortal races and demons. In the hierarchy of the infernal realms, they typically occupy the niche of disenfranchised labor, although some archdevils allow tieflings to hold more significant positions in their domains. \
	Tieflings arrive in the lands of Grimoria in two ways — either fleeing the Inferno, or being born on mortal lands as one of the unfortunate consequences of demonic invasions. The attitude of other races toward these two categories of half-bloods varies greatly. Those who came into being due to demon attacks are considered a curse upon their entire lineage for obvious reasons; they are persecuted and despised. On the other hand, those who left the Inferno of their own will often enjoy far greater respect, especially if it was the result of an armed uprising. Tieflings who went against their demonic nature and proved it in deed became the founders of several noble lines in Zybantia, Grenzelhoft, and Azuria."
	origin_default = /datum/virtue/origin/racial/infernal
	origin = "Infernal"
	languages = list(/datum/language/common)
	base_name = "Demonkin"
	is_subrace = FALSE

/datum/species/elf
	languages = list(/datum/language/common)

/datum/species/elf/wood
	sub_name = "Northern Elf"
	desc_title = "Northern Elves"
	desc = "Elves are one of the oldest races of Grimoria, distinguished by a rich history and refined culture. Endowed with longevity and the wisdom of centuries, it was the elves who founded the Divine Empire, which served as the backbone of the Pantheon of the Primordial Five in the lands now belonging to the Western Kingdoms. \
	After the fall of the Divine Empire, a significant portion of elves journeyed north, away from the ravaged imperial lands. These refugees — the future northern elves — founded Hammerhold and settled the lands of the Narrow Sea (now a vassal of Grenzelhoft), and some even reached Gronn. The northern elves adapted to the harsh climate and rugged way of life of their new homeland. They adopted many customs of the human society of Hammerhold without losing their race's characteristic longevity and aristocratic refinement. The culture of the northern elves is a fusion of imperial heritage with the pragmatism of the north, where resilience, discipline, and readiness for defense against the countless threats of the Wild North are valued."

/datum/species/elf/sun
	desc_title = "Sun Elves"
	desc = "Elves are one of the oldest races of Grimoria, distinguished by a rich history and refined culture. Endowed with longevity and the wisdom of centuries, it was the elves who founded the Divine Empire, which served as the backbone of the Pantheon of the Primordial Five in the lands now belonging to the Western Kingdoms. \
	Sun elves are those who could not accept the end of the Divine Empire. They remained on the former imperial lands: in Etrusca, Valoria, and the prefecture of Raneshen of the Zybantian Empire, continuing to preserve the traditions and the cult of Astrata. Unlike their pragmatic northern kin, sun elves live in the past. They devoutly honor the rituals of the Divine Empire, maintain ancient temples, and continue to believe that the favor of the Pantheon can be restored. Their societies are characterized by conservatism, adherence to strict hierarchy, and deep reverence for Astrata as the first among the Undivided Pantheon."
	origin_default = /datum/virtue/origin/etrusca
	origin = "Etrusca"

/datum/species/elf/dark
	desc_title = "Dark Elves"
	desc = "Long ago, when empires in their current form did not yet exist, but the division of elves into tribes already did, one tribe desired to rise above the rest, taking the path of war under the leadership of the Spider Queens. Their ideas captured many minds, an eternal thirst for power and domination led to many brutal battles, but only the rout of the drow by the forces of the other clans gave the final push to the formation of this people in the form in which it exists today. Having lost the greater part of their forces, the drow were forced to flee to the Underdark, where a new chapter of their history began. \
	Finding themselves in such an inhospitable environment, the former elves had to change, not without the help of the arcane might of the Spider Queens. Their skin darkened significantly, their hair turned white, and their eyes, having adapted to the darkness, turned red. The Queens endowed the women with far greater physical strength than the men, which is why matriarchy reigns supreme everywhere in their cities. The high priestesses of the Spider Queens occasionally received their blessing in the form of a metamorphosis that endows them with spider-like traits, but encountering such a one on the surface in these times is a rarity."
	origin_default = /datum/virtue/origin/racial/underdark_drow
	origin = "the Underdark"

/datum/species/dullahan
	desc_title = "Dullahans"
	desc = "Little is known about the sinister dullahans who originate from the ice of Mandira — one of the realms of the Inferno. The most common theory of their origin revolves around the Inferno's property of altering and corrupting representatives of mortal races who find themselves in the chaotic environment of this Plane over time. It is believed that those of the races of Grimoria who are unfortunate enough to perish in the lands of Mandira — or become trapped in them long enough for the corruptive influence of these lands, forever tainted by the power of unlife since Zizo's invasion, to become irreversible — become dullahans. \
	Revenants began appearing in the lands of Grimoria relatively recently — the first encounter with them was recorded in the chronicles of Otava seventy years ago. Like the tieflings before them, revenants cross the boundary between Planes, fleeing the Inferno for various reasons. Their unnatural nature, however, has become a cause for distrust and apprehension among the inhabitants of Grimoria — where tieflings are accepted, and sometimes even exalted for their willingness to fight their demonic nature, dullahans are feared and rejected throughout the world. The less educated segments of the population not unreasonably mistake them for servants of Zizo, with predictable results."
	origin_default = /datum/virtue/origin/racial/infernal
	origin = "Infernal"
	languages = list(/datum/language/common)
	base_name = "Demonkin"

/datum/species/aasimar
	desc_title = "Aasimars"
	desc = "The first aasimars were created by Malum shortly after his ascension to the Pantheon. Unwilling to lose his connection with his flock, the dwarf chosen to become a deity blessed certain mortal women to bear divine messengers, who were endowed with the ability to hear the dictums of celestials in their dreams, and sometimes even while awake. Possessing a portion of their creator's divine power, these messengers were met by mortals with awe and respect, and their words were often interpreted as the ultimate truth. As aasimars proved their usefulness, all the deities of the Pantheon, as well as the Allfather himself, adopted this practice, creating their own messengers among the mortal races of Grimoria. \
	It is said that the power of an aasimar can slumber in a family's genetic line for many generations, until its time comes. At least, this is how the birth of aasimars to ordinary mortal couples is explained in our days. Despite the fact that the former reverence for divine messengers is no longer as widespread, the birth of an aasimar is still considered a blessed omen for the family, and the aasimar themselves, as well as their parents, often find themselves surrounded by honor and respect. \
	The Church of the Ten categorically denies any claims that some aasimars originate not from the Ten or the Allfather, but from the deities of the Despised Pantheon."
	origin_default = /datum/virtue/origin/valorian
	origin = "Valoria"
	languages = list(/datum/language/common)

/datum/species/dracon
	desc_title = "Draconians"
	desc = "Draconians, also called dragonkin, are a species of humanoid sentient reptiles tracing their roots back to dragons. \
	The first mentions of draconians date back to the 4th century before the New Order. Theories on how exactly they appeared in Grimoria range from interbreeding of dragons in mortal guise with other races to experiments aimed at replicating the ancient and powerful dragon nature. The dragons themselves, in turn, often call draconians a 'mistake' and refuse to explain in detail. \
	Throughout their history, dragonkin have remained a small and scattered people. No chronicle contains a documented draconian state; instead, representatives of this race are frequently mentioned among the prominent nobility of many states past and present, including the Divine Empire, Valoria, the Golden Empire, and the Otavan Theocracy."
	max_age = 1900
	origin_default = /datum/virtue/origin/racial/ancient
	origin = "Age Long Gone"
	base_name = "Dragonkin"
	languages = list(/datum/language/common)

/datum/species/human/halfelf
	desc_title = "Half-Elves"
	desc = "Half-elves are the result of interracial unions between humans and elves. Only partially inheriting the power of ancient elven blood, half-bloods nevertheless often possess the longevity and refinement characteristic of elves. Among their pure-blooded kin, half-elves usually face resentment or open hostility, while humans may find it difficult to distinguish them from a full-blooded elf. \
	An even rarer category among half-bloods are half-drow. Even those dark elves who have been exiled from the Underdark rarely allow members of other races near them, which is why encountering a half-drow is an exceedingly rare event. They are easily distinguished from their pure-blooded brethren by their lighter skin and hair colors unusual for drow."
	languages = list(/datum/language/common)

/datum/species/halforc
	desc_title = "Half-Orcs"
	desc = "Half-orcs are the result of interracial unions between an orc and a human, with the mother belonging to the orcish race in the vast majority of cases. Despite the barbaric nature of their blood, half-orcs are typically raised in a quite traditional manner, which allows them to be surprisingly intelligent for their appearance."
	languages = list(/datum/language/common)

/datum/species/vulpkanin
	desc_title = "Vendarins"
	desc = "At first glance, a vendarin can easily be mistaken for a member of the lupian race — so similar can they appear. Nevertheless, while lupians are an actual evolution of wolves, accelerated by the will of the Lady of Night, the origin of vendarins is presumably not connected to divine intervention at all. Like the tabaxi, they appeared after the War in the Heavens in the lands now belonging to the Grenzelhoft Empire. Unlike the predominantly tribal lupians, the main population of vendarins is concentrated in cities, where they occupy the niche of active merchants, intellectuals, and the middle burgher class; many influential patrician families of the free cities are also vendarin."
	languages = list(/datum/language/common)

/datum/species/kobold
	desc_title = "Kobolds"
	desc = "Kobolds are a reptilian humanoid race. Their height ranges from 70 to 120 centimeters, their skin is covered in scales of various colors, and their eye color varies from purple to orange and red hues. Their legs are sinewy and digitigrade. They have long clawed fingers and a crocodile-like jaw. Small white or light-brown horns protrude from their heads, and their tails resemble those of rats. Researchers assert a definite connection between kobolds, draconians, and dragons — presumably, the former are significantly degenerated distant descendants of the latter."
	origin_default = /datum/virtue/origin/racial/lirvas
	origin = "Lirvas"
	base_name = "Dragonkin"
	languages = list(/datum/language/common)

/datum/species/anthromorph
	desc_title = "Wildkins"
	desc = "How exactly mortals become beast-like is not reliably known to this day. Some half-bloods, quite predictably, are the result of interracial crossbreeding, although far more often such unions produce no offspring at all. At the same time, beast-like children can sometimes appear to ordinary couples — the causes of this phenomenon remain unclear, and some call it a curse of the gods, generally attributing it to Dendor or Xylix. \
	Another source of beast-like beings is powerful magical rituals. Thus, the magical storm that destroyed the Crimson Lands turned all the survivors of the cataclysm in those lands into wildkins. Given how rare the birth of a halfkin or wildkin is by ordinary means, it is in the Crimson Lands that the largest population of beast-like beings currently resides."
	languages = list(/datum/language/common)

/datum/species/anthromorphsmall
	desc_title = "Verminwolves"
	desc = "How exactly mortals become beast-like is not reliably known to this day. Some half-bloods, quite predictably, are the result of interracial crossbreeding, although far more often such unions produce no offspring at all. At the same time, beast-like children can sometimes appear to ordinary couples — the causes of this phenomenon remain unclear, and some call it a curse of the gods, generally attributing it to Dendor or Xylix. \
	Another source of beast-like beings is powerful magical rituals. Thus, the magical storm that destroyed the Crimson Lands turned all the survivors of the cataclysm in those lands into wildkins. Given how rare the birth of a halfkin or wildkin is by ordinary means, it is in the Crimson Lands that the largest population of beast-like beings currently resides."
	languages = list(/datum/language/common)

/datum/species/demihuman
	desc_title = "Halfkins"
	desc = "How exactly mortals become beast-like is not reliably known to this day. Some half-bloods, quite predictably, are the result of interracial crossbreeding, although far more often such unions produce no offspring at all. At the same time, beast-like children can sometimes appear to ordinary couples — the causes of this phenomenon remain unclear, and some call it a curse of the gods, generally attributing it to Dendor or Xylix. \
	Another source of beast-like beings is powerful magical rituals. Thus, the magical storm that destroyed the Crimson Lands turned all the survivors of the cataclysm in those lands into wildkins. Given how rare the birth of a halfkin or wildkin is by ordinary means, it is in the Crimson Lands that the largest population of beast-like beings currently resides."
	languages = list(/datum/language/common)

/datum/species/lizardfolk
	desc_title = "Zardmen"
	desc = "Zardmen are reptilian humanoids, claimed by some researchers to be even more degenerated descendants of the proud draconians. Their flesh is covered in scales, whose color varies from dark green to shades of brown and gray. Zardmen are taller than humans and possess a powerful build; their height often ranges from 6 to 7 feet. Zardmen have muscular tails reaching three to four feet in length, which are used for maintaining balance. They also possess sharp claws and teeth."
	origin_default = /datum/virtue/origin/racial/lirvas
	origin = "Lirvas"
	base_name = "Dragonkin"
	languages = list(/datum/language/common)

/datum/species/lupian
	desc_title = "Lupians"
	desc = "According to ancient legends, in the beginning of times, wolves were the favorite creations of Dendor, the First Beast. They howled at the moon every night, and their voices reached the heavens where Noc dwelled. The Moon Goddess heard in the wolves' howling something more than animal instinct — she heard a longing for something unattainable, a striving for knowledge. And Noc, the mistress of knowledge and dreams, decided to answer this call. \
	On one night of the full moon, she descended to the wolf pack and touched them with her light. Those wolves that looked directly at the moon received the Lunar Gift — a spark of reason, the ability to think and speak. Their bodies changed, gaining the ability to walk on two legs, and their souls awakened to awareness of the world. \
	Thus the first lupians appeared — wolves who became something greater under the influence of Noc."
	languages = list(/datum/language/common)

/datum/species/moth
	desc_title = "Fluvians"
	desc = "Many comparisons to ordinary moths have been made to describe this unique species. From their appetite for clothing to their frighteningly insectoid appearance, the name 'moth' has become permanently entrenched in common usage. However, this comparison does not quite accurately reflect their ability — or rather, the lack thereof — to fly."
	languages = list(/datum/language/common)

/datum/species/tabaxi
	desc_title = "Tabaxi"
	desc = "Tabaxi, presumably originating from the southern regions of the Western Kingdoms, are taller than most humans, standing from six to seven feet. Their bodies are slender and covered in spotted or striped fur. Like most felines, tabaxi have long tails and retractable claws. The fur color of tabaxi ranges from light yellow to reddish-brown. Tabaxi eyes are slit-pupiled, usually green or yellow. Tabaxi are skilled swimmers, climbers, and fast runners. They possess a good sense of balance and a keen sense of smell."
	origin_default = /datum/virtue/origin/zybantian
	origin = "Zybantu"
	languages = list(/datum/language/common)

/datum/species/akula
	desc_title = "Axians"
	desc = "Axians are a proud, shark-like people whose culture is based on maritime trade, tax evasion, and piracy."
	languages = list(/datum/language/common)

/datum/species/construct/metal
	desc_title = "Constructs"
	desc = "The origin of these automatons is shrouded in mystery. The constructs themselves claim they were originally created by Zizo, the Lady of Darkness, in the aftermath of the betrayal by her closest ally, Xylix. It is unknown where the main population of constructs currently resides, and whether they truly serve the Arch-Traitor, but those encountered in the lands of the Western Kingdoms are free from her influence. At least, that is what they claim."
	origin_default = /datum/virtue/origin/heartfelt
	origin = "Heartfelt"
	languages = list(/datum/language/common)

/datum/species/dwarf/mountain
	desc_title = "Dwarves"
	desc = "Dwarves are one of the oldest races, born of stone, dwellers of mountains and the deepest mines. They are renowned throughout the world not only for their craft and technology, but also for their stubbornness, relentlessness, and a rather foul temper and pride. The dwarves call themselves akhdruki, which can be translated as 'heirs of the mountains.' Adherence to tradition and reverence for ancestors is, without exaggeration, an integral part of any dwarf's life. \
	The appearance of this race perfectly demonstrates their connection to their habitats. Dwarves are naturally short and stocky, but possess incredible endurance, strength, unyielding resilience, and stubbornness. It is no surprise that many other races often mockingly compare them to — and in the case of dwarves, embody — stone or mountain. Most dwarves stand only 90-140 cm tall, yet they are sturdily built, with strong thick arms, broad shoulders, short but powerful legs, and a barrel-like torso. Female dwarves have a similar build, though they are much more voluptuous."
	origin_default = /datum/virtue/origin/racial/akhdruk
	origin = "Drud Akhdruk"
	languages = list(/datum/language/common)

/datum/species/goblinp
	desc_title = "Goblins"
	desc = "Goblins are a short race of humanoids with large ears and usually green skin. Presumably, they were formed from the blood spilled when the fierce God of War Graggar was wounded by Ravox. Although most goblins still heed the call of their tainted blood, worshipping Graggar and remaining aggressive toward all they encounter, some of them do display free will, forming secluded enclaves where they hide from both their kin and the persecution of other sentient races. Only recently, in the last few centuries, have sentient goblins begun to leave their isolated villages and tribes to seek their future in civilized society, striving to overcome the discrimination and distrust of the Church, states, and peoples of Grimoria."
	languages = list(/datum/language/common)
