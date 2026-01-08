function [tags_full_str,tags_str]=get_tags_str(type,inwr)
% Get the tags of an OSM map feature as character array
% Example (a specific OSM dataset must be loaded):
% [tags_full_str,tags_str]=get_tags_str('way',40)
% tags_full_str =
%     'ID:   OSMDATA.id.way(1,40)=225698612
%            addr:city = München
%            addr:country = DE
%            addr:housenumber = 1
%            addr:postcode = 80331
%            addr:street = Frauenplatz
%            amenity = place_of_worship
%            architect = Jörg von Halspach
%            architect:wikidata = Q123464
%            building = church
%            building:architecture = gothic
%            building:shape = basilicas
%            building:year = 1468
%            denomination = catholic
%            diocese = Erzbistum München und Freising
%            height = 37
%            heritage = 4
%            heritage:operator = BLfD
%            name = Frauenkirche
%            name:bar = Fraunkirch
%            name:de = Frauenkirche
%            name:el = Φράουενκιρχε
%            name:ru = Фрауэнкирхе
%            name:zh = 聖母主教座堂 (慕尼黑)
%            official_name = Dom zu Unserer Lieben Frau
%            official_name:de = Dom zu Unserer Lieben Frau
%            official_name:ru = Собор Пресвятой Девы Марии
%            ref:BLfD = D-1-62-000-1808
%            religion = christian
%            toilets:wheelchair = no
%            tourism = attraction
%            website = https://www.muenchner-dom.de/
%            wheelchair = limited
%            wheelchair:description = kein Rolli-WC
%            wikidata = Q167193
%            wikimedia_commons = Category:Frauenkirche (Munich)
%            wikipedia = de:Frauenkirche (München)
%      '
% tags_str =
%     'ID:   OSMDATA.id.way(1,40)=225698612
%            addr:city = München
%            addr:country = DE
%            addr:housenumber = 1
%            addr:postcode = 80331
%            addr:street = Frauenplatz
%            amenity = place_of_worship
%            architect = Jörg von Halspach
%            architect:wikidata = Q123464
%            building = church
%            building:architecture = gothic
%            building:shape = basilicas
%            building:year = 1468
%            denomination = catholic
%            diocese = Erzbistum München und Freising
%            height = 37
%      ...'

global OSMDATA

tags_str			= '';
tags_full_str	= sprintf('ID:   OSMDATA.id.%s(1,%g)=%1.0f\n',type,inwr,OSMDATA.id.(type)(1,inwr));
if ~ismissing(OSMDATA.(type)(1,inwr).tag(1,1))
	for it = 1:size(OSMDATA.(type)(1,inwr).tag,2)
		tags_full_str = sprintf('%s      %s = %s\n',tags_full_str, OSMDATA.(type)(1,inwr).tag(1,it).k,OSMDATA.(type)(1,inwr).tag(1,it).v);
		if it == 15
			tags_str	= sprintf('%s...',tags_full_str);
		end
	end
else
	tags_full_str = sprintf('%s      no tags\n',tags_full_str);
end

if isempty(tags_str)
	tags_str	= tags_full_str;
end


