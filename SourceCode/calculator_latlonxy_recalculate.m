function calculator_latlonxy_recalculate(dataset)
% This function calculates all data anew after changing general data like scale, origin, frame width, ...

global APP

try

	if nargin==0
		% Recalculate OSM data:
		calculator_latlonxy_recalculate('OSM');
		% Recalculate Osmosis settings:
		calculator_latlonxy_recalculate('Osmosis');
		% Recalculate map printout:
		calculator_latlonxy_recalculate('Map');
		return
	end
	if nargin==1
		switch dataset					% 'OSM', 'Osmosis', 'Map'
			case 'OSM'
				% Recalculate OSM data: Keep the latlon-values:
				calculator_latlon_xy('OSM');			% executes also calculator_latlonxy_recalculate('PrintoutSize_OSM')
			case 'Osmosis'
				% Recalculate Osmosis settings: Keep the latlon-values:
				calculator_latlon_xy('Osmosis');		% executes also calculator_latlonxy_recalculate('PrintoutSize_Osmosis')
			case 'Map'
				% Recalculate map printout data: Keep the xy-values:
				calculator_xy_latlon('Map');			% executes also calculator_latlonxy_recalculate('PrintoutSize_Map')
			case 'PrintoutSize'
				% Recalculate all printout sizes:
				calculator_latlonxy_recalculate('PrintoutSize_OSM');
				calculator_latlonxy_recalculate('PrintoutSize_Osmosis');
				calculator_latlonxy_recalculate('PrintoutSize_Map');

			case 'PrintoutSize_OSM'
				% Recalculate OSM data printout size:
				[...
					APP.LatLonXYTab_OSM_Wmm_Label.Text,...			% width (W=xmax-xmin)
					APP.LatLonXYTab_OSM_Hmm_Label.Text,...			% depth (D=ymax-ymin)
					APP.LatLonXYTab_OSM_NoTilesW_Label.Text,...	% number of tiles x-direction
					APP.LatLonXYTab_OSM_NoTilesH_Label.Text,...	% number of tiles y-direction
					APP.LatLonXYTab_OSM_TWminmm_Label.Text,...	% min. tile width at the same printout width
					APP.LatLonXYTab_OSM_TWmaxmm_Label.Text,...	% max. tile width at the same printout width
					APP.LatLonXYTab_OSM_THminmm_Label.Text,...	% min. tile depth at the same printout depth
					APP.LatLonXYTab_OSM_THmaxmm_Label.Text,...	% max. tile depth at the same printout depth
					APP.LatLonXYTab_OSM_Wminmm_Label.Text,...		% min. printout width at the same number of tiles and tile size
					APP.LatLonXYTab_OSM_Wmaxmm_Label.Text,...		% max. printout width at the same number of tiles and tile size
					APP.LatLonXYTab_OSM_Hminmm_Label.Text,...		% min. printout depth at the same number of tiles and tile size
					APP.LatLonXYTab_OSM_Hmaxmm_Label.Text...		% max. printout depth at the same number of tiles and tile size
					]=recalc_printoutsize(...
					APP.LatLonXYTab_OSM_xminmmEditField.Value,...	% xmin
					APP.LatLonXYTab_OSM_xmaxmmEditField.Value,...	% xmax
					APP.LatLonXYTab_OSM_yminmmEditField.Value,...	% ymin
					APP.LatLonXYTab_OSM_ymaxmmEditField.Value);		% ymax

			case 'PrintoutSize_Osmosis'
				% Recalculate Osmosis settings printout size:
				[...
					APP.LatLonXYTab_Osmosis_Wmm_Label.Text,...		% width (W=xmax-xmin)
					APP.LatLonXYTab_Osmosis_Hmm_Label.Text,...		% depth (D=ymax-ymin)
					APP.LatLonXYTab_Osmosis_NoTilesW_Label.Text,...	% number of tiles x-direction
					APP.LatLonXYTab_Osmosis_NoTilesH_Label.Text,...	% number of tiles y-direction
					APP.LatLonXYTab_Osmosis_TWminmm_Label.Text,...	% min. tile width at the same printout width
					APP.LatLonXYTab_Osmosis_TWmaxmm_Label.Text,...	% max. tile width at the same printout width
					APP.LatLonXYTab_Osmosis_THminmm_Label.Text,...	% min. tile depth at the same printout depth
					APP.LatLonXYTab_Osmosis_THmaxmm_Label.Text,...	% max. tile depth at the same printout depth
					APP.LatLonXYTab_Osmosis_Wminmm_Label.Text,...	% min. printout width at the same number of tiles and tile size
					APP.LatLonXYTab_Osmosis_Wmaxmm_Label.Text,...	% max. printout width at the same number of tiles and tile size
					APP.LatLonXYTab_Osmosis_Hminmm_Label.Text,...	% min. printout depth at the same number of tiles and tile size
					APP.LatLonXYTab_Osmosis_Hmaxmm_Label.Text...		% max. printout depth at the same number of tiles and tile size
					]=recalc_printoutsize(...
					APP.LatLonXYTab_Osmosis_xminmmEditField.Value,...	% xmin
					APP.LatLonXYTab_Osmosis_xmaxmmEditField.Value,...	% xmax
					APP.LatLonXYTab_Osmosis_yminmmEditField.Value,...	% ymin
					APP.LatLonXYTab_Osmosis_ymaxmmEditField.Value);		% ymax

			case 'PrintoutSize_Map'
				% Recalculate map printout data printout size:
				[...
					APP.LatLonXYTab_Map_Wmm_Label.Text,...			% width (W=xmax-xmin)
					APP.LatLonXYTab_Map_Hmm_Label.Text,...			% depth (D=ymax-ymin)
					APP.LatLonXYTab_Map_NoTilesW_Label.Text,...	% number of tiles x-direction
					APP.LatLonXYTab_Map_NoTilesH_Label.Text,...	% number of tiles y-direction
					APP.LatLonXYTab_Map_TWminmm_Label.Text,...	% min. tile width at the same printout width
					APP.LatLonXYTab_Map_TWmaxmm_Label.Text,...	% max. tile width at the same printout width
					APP.LatLonXYTab_Map_THminmm_Label.Text,...	% min. tile depth at the same printout depth
					APP.LatLonXYTab_Map_THmaxmm_Label.Text,...	% max. tile depth at the same printout depth
					APP.LatLonXYTab_Map_Wminmm_Label.Text,...		% min. printout width at the same number of tiles and tile size
					APP.LatLonXYTab_Map_Wmaxmm_Label.Text,...		% max. printout width at the same number of tiles and tile size
					APP.LatLonXYTab_Map_Hminmm_Label.Text,...		% min. printout depth at the same number of tiles and tile size
					APP.LatLonXYTab_Map_Hmaxmm_Label.Text...		% max. printout depth at the same number of tiles and tile size
					]=recalc_printoutsize(...
					APP.LatLonXYTab_Map_xminmmEditField.Value,...	% xmin
					APP.LatLonXYTab_Map_xmaxmmEditField.Value,...	% xmax
					APP.LatLonXYTab_Map_yminmmEditField.Value,...	% ymin
					APP.LatLonXYTab_Map_ymaxmmEditField.Value);		% ymax

		end
	end

catch ME
	errormessage('',ME);
end



function [...
	w_str,...					% width (W=xmax-xmin)
	h_str,...					% depth (D=ymax-ymin)
	ntx_str,...					% number of tiles x-direction
	nty_str,...					% number of tiles y-direction
	wtmin_str,...				% min. tile width at the same number of tiles and printout width
	wtmax_str,...				% max. tile width at the same number of tiles and printout width
	htmin_str,...				% min. tile depth at the same number of tiles and printout depth
	htmax_str,...				% max. tile depth at the same number of tiles and printout depth
	wmin_str,...				% min. printout width at the same number of tiles and tile size
	wmax_str,...				% max. printout width at the same number of tiles and tile size
	hmin_str,...				% min. printout depth at the same number of tiles and tile size
	hmax_str...					% max. printout depth at the same number of tiles and tile size
	]=recalc_printoutsize(...
	xmin,...						% printout dimensions without frame
	xmax,...
	ymin,...
	ymax)

global APP

try

	wtmin_str= '';
	wtmax_str= '';
	htmin_str= '';
	htmax_str= '';


	% Width and depth (here called height):
	w					= xmax-xmin;
	h					= ymax-ymin;
	if w>=0
		w_str				= sprintf('%1.2f mm',w);
	else
		w_str				= '';
	end
	if h>=0
		h_str				= sprintf('%1.2f mm',h);
	else
		h_str				= '';
	end

	% Printout sizes:

	wt					= APP.LatLonXYTab_TileWidth_EditField.Value;
	ht					= APP.LatLonXYTab_TileHeight_EditField.Value;
	fw					= APP.LatLonXYTab_FrameWidth_EditField.Value;

	ntx				= ceil((w+2*fw)/wt);
	nty				= ceil((h+2*fw)/ht);

	wtmin				= (w+2*fw)/ntx;
	wtmax				= (w+2*fw)/(ntx-1);		% in Klammern
	htmin				= (h+2*fw)/nty;
	htmax				= (h+2*fw)/(nty-1);
	wtmin_str		= sprintf('%1.2f mm',wtmin);
	if ntx>1
		wtmax_str	= sprintf('(%1.2f mm)',wtmax);
	else
		wtmax_str	= '---';
	end
	htmin_str		= sprintf('%1.2f mm',htmin);
	if nty>1
		htmax_str	= sprintf('(%1.2f mm)',htmax);
	else
		htmax_str	= '---';
	end

	wmin				= (ntx-1)*wt -2*fw;
	wmax				=  ntx   *wt -2*fw;
	hmin				= (nty-1)*ht-2*fw;
	hmax				=  nty   *ht-2*fw;
	if ntx>1
		wmin_str		= sprintf('(%1.2f mm)',wmin);
	else
		wmin_str		= '---';
	end
	wmax_str			= sprintf('%1.2f mm',wmax);
	if nty>1
		hmin_str		= sprintf('(%1.2f mm)',hmin);
	else
		hmin_str		= '---';
	end
	hmax_str			= sprintf('%1.2f mm',hmax);
	if ntx==1
		ntx_str		= sprintf('%1.0f',ntx);
	elseif ntx>0
		ntx_str		= sprintf('%1.0f',ntx);
	else
		% ntx=<0:
		ntx_str		= '---';
		wmax_str		= '---';
	end
	if nty==1
		nty_str		= sprintf('%1.0f',nty);
	elseif nty>0
		nty_str		= sprintf('%1.0f',nty);
	else
		% nty=<0:
		nty_str		= '---';
		hmax_str		= '---';
	end

catch ME
	errormessage('',ME);
end

