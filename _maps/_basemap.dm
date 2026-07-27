#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\dun_world\dun_world.dmm"
		#include "map_files\roguetest\roguetest.dmm"
		#include "map_files\otherz\wretch_coast.dmm"
		#include "map_files\gen_1\hargh_map.dmm"

		#ifdef ALL_TEMPLATES
			#include "templates.dm"
		#endif

	#endif
#endif
