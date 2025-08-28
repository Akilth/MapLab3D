function errortext=verify_pp_values(pp,varname_dataset_no)
% Check the project parameter values:

% Work in progress !!!

% Werte der Projektparameter auf Richtigkeit und Plausibilität prüfen
% insbesondere falsche Werte von
% colno
% icolspec
% chstno
% iobj
% können zum Programmabsturz führen.
% Auch prüfen, ob z. B. das Objekt definiert ist (~isempty(pp.obj(iobj).display)).
% Ansatz siehe verify_pp_values, ist aber auf diese Art umständlich.
% Zusatzspalten in MapLab3D_PP_Reference mit:
% Minimum, Maximum, Typ (colno, ...), Zahlentyp (int, ...) ???

global GV

try

	if nargin==0
		global PP
		pp							= PP;
		varname_dataset_no	= GV.varname_dataset_no;
		clc

		% 	pp.obj(10,1).prio=54232;
		% 	pp.obj(43,1).symbolpar.prio=54232;
		% 	pp.obj(41,1).symbolpar.prio=4.5;
		% 	pp.obj(1,1).prio=12;
		% 	pp.obj(2,1).prio=10;

	end

	colno_max		= size(pp.color,1);
	icolspec_max	= size(pp.colorspec,1);
	chstno_max		= size(pp.charstyle,1);
	iobj_max			= size(pp.obj,1);

	errortext		= '';

	% Object, text and symbol priorities:
	% preparation:
	obj_iobj_v			= (1:iobj_max)';
	obj_prio_v			= -9999*ones(iobj_max,1);
	obj_rowno_c			= cell(iobj_max,1);
	obj_dscr_c			= cell(iobj_max,1);
	obj_varname_c		= cell(iobj_max,1);
	all_iobj_v			= (1:(3*iobj_max))';
	all_prio_v			= -9999*ones(3*iobj_max,1);
	all_rowno_c			= cell(3*iobj_max,1);
	all_dscr_c			= cell(3*iobj_max,1);
	all_varname_c		= cell(3*iobj_max,1);
	for iobj=1:iobj_max
		k			= 3*(iobj-1);
		obj_varname_c{iobj,1}		= sprintf('obj(%1.0f,1).prio',iobj);
		all_varname_c{k+1,1}			= sprintf('obj(%1.0f,1).prio',iobj);
		all_varname_c{k+2,1}			= sprintf('obj(%1.0f,1).textpar.prio',iobj);
		all_varname_c{k+3,1}			= sprintf('obj(%1.0f,1).symbolpar.prio',iobj);
		if isempty(pp.obj(iobj,1).prio)
			obj_prio_v(iobj,1)		= -1;
			all_prio_v(k+1,1)			= -1;
			all_prio_v(k+2,1)			= -1;
			all_prio_v(k+3,1)			= -1;
			obj_rowno_c{iobj,1}		= '---';
			obj_dscr_c{iobj,1}		= '---';
			all_rowno_c{k+1,1}		= '---';
			all_rowno_c{k+2,1}		= '---';
			all_rowno_c{k+3,1}		= '---';
			all_dscr_c{k+1,1}			= '---';
			all_dscr_c{k+2,1}			= '---';
			all_dscr_c{k+3,1}			= '---';
		else
			obj_prio_v(iobj,1)		= pp.obj(iobj,1).prio;
			all_prio_v(k+1,1)			= pp.obj(iobj,1).prio;
			all_prio_v(k+2,1)			= pp.obj(iobj,1).textpar.prio;
			all_prio_v(k+3,1)			= pp.obj(iobj,1).symbolpar.prio;
			obj_rowno_c{iobj,1}		= num2str(pp.TABLE_ROWNO.obj(iobj,1).prio);
			obj_dscr_c{iobj,1}		= pp.DESCRIPTION.obj{iobj,1}.prio{1,1};
			all_rowno_c{k+1,1}		= num2str(pp.TABLE_ROWNO.obj(iobj,1).prio);
			all_dscr_c{k+1,1}			= pp.DESCRIPTION.obj{iobj,1}.prio{1,1};
			if ~isfield(pp.TABLE_ROWNO.obj(iobj,1),'textpar')
				all_rowno_c{k+2,1}	= '---';
				all_dscr_c{k+2,1}		= '---';
			else
				if isempty(pp.TABLE_ROWNO.obj(iobj,1).textpar)
					all_rowno_c{k+2,1}	= '---';
					all_dscr_c{k+2,1}		= '---';
				else
					if ~isfield(pp.TABLE_ROWNO.obj(iobj,1).textpar,'prio')
						all_rowno_c{k+2,1}	= '---';
						all_dscr_c{k+2,1}		= '---';
					else
						if isempty(pp.TABLE_ROWNO.obj(iobj,1).textpar.prio)
							all_rowno_c{k+2,1}	= '---';
							all_dscr_c{k+2,1}		= '---';
						else
							all_rowno_c{k+2,1}	= num2str(pp.TABLE_ROWNO.obj(iobj,1).textpar.prio);
							all_dscr_c{k+2,1}		= pp.DESCRIPTION.obj{iobj,1}.textpar{1,1}.prio{1,1};
						end
					end
				end
			end
			if ~isfield(pp.TABLE_ROWNO.obj(iobj,1),'symbolpar')
				all_rowno_c{k+3,1}	= '---';
				all_dscr_c{k+3,1}		= '---';
			else
				if isempty(pp.TABLE_ROWNO.obj(iobj,1).symbolpar)
					all_rowno_c{k+3,1}	= '---';
					all_dscr_c{k+3,1}		= '---';
				else
					if ~isfield(pp.TABLE_ROWNO.obj(iobj,1).symbolpar,'prio')
						all_rowno_c{k+3,1}	= '---';
						all_dscr_c{k+3,1}		= '---';
					else
						if isempty(pp.TABLE_ROWNO.obj(iobj,1).symbolpar.prio)
							all_rowno_c{k+3,1}	= '---';
							all_dscr_c{k+3,1}		= '---';
						else
							all_rowno_c{k+3,1}	= num2str(pp.TABLE_ROWNO.obj(iobj,1).symbolpar.prio);
							all_dscr_c{k+3,1}		= pp.DESCRIPTION.obj{iobj,1}.symbolpar{1,1}.prio{1,1};
						end
					end
				end
			end
		end
		all_iobj_v(k+1,1)			= iobj;
		all_iobj_v(k+2,1)			= iobj;
		all_iobj_v(k+3,1)			= iobj;
	end
	% - prio: whole numbers
	for k=1:size(all_prio_v,1)
		if ~isequal(all_prio_v(k,1),-1)
			if    (all_prio_v(k,1) <1                     )||...
					(all_prio_v(k,1)~=round(all_prio_v(k,1)))
				errortext	= sprintf([...
					'Error:\n',...
					'Invalid value of the project parameter in\n',...
					'row %s, column %s:\n',...
					'%s:\n',...
					'%s = %g\n',...
					'The value must be a whole number >=1.'],...
					all_rowno_c{k,1},...
					varname_dataset_no,...
					all_dscr_c{k,1},...
					all_varname_c{k,1},...
					all_prio_v(k,1));
				return
			end

		end
	end
	% - maximum difference between two values object prio (not text/symbol prio): 3
	%   because: text   prio: object prio +1
	%            symbol prio: object prio +2
	[obj_prio_sort_v,i_sort]					= sort(obj_prio_v);
	obj_iobj_sort_v								= obj_iobj_v(i_sort);
	obj_iobj_sort_v(obj_prio_sort_v==-1)	= [];
	obj_prio_sort_v(obj_prio_sort_v==-1)	= [];
	diff_obj_prio_sort_v			= diff(obj_prio_sort_v);
	k_error							= find(diff_obj_prio_sort_v<3,1);
	if ~isempty(k_error)
		iobj1			= obj_iobj_sort_v(k_error);
		iobj2			= obj_iobj_sort_v(k_error+1);
		if iobj1>iobj2
			iobj1		= obj_iobj_sort_v(k_error+1);
			iobj2		= obj_iobj_sort_v(k_error);
		end
		errortext	= sprintf([...
			'Error:\n',...
			'Invalid values of the project parameters in\n',...
			'row %s, column %s and\n',...
			'row %s, column %s:\n',...
			'%s = %g\n',...
			'%s = %g\n',...
			'The difference must be >=3.'],...
			obj_rowno_c{iobj1,1},...
			varname_dataset_no,...
			obj_rowno_c{iobj2,1},...
			varname_dataset_no,...
			obj_varname_c{iobj1,1},obj_prio_v(iobj1,1),...
			obj_varname_c{iobj2,1},obj_prio_v(iobj2,1));
		return
	end
	% - unique priorities of objects, texts, symbols:
	[all_prio_sort_v,i_sort]		= sort(all_prio_v);
	all_iobj_sort_v					= all_iobj_v(i_sort);
	all_rowno_sort_c					= all_rowno_c(i_sort);
	all_varname_sort_c				= all_varname_c(i_sort);
	k_delete								= (all_prio_sort_v==-1);
	all_iobj_sort_v(k_delete)		= [];
	all_prio_sort_v(k_delete)		= [];
	all_rowno_sort_c(k_delete)		= [];
	all_varname_sort_c(k_delete)	= [];
	diff_all_prio_sort_v				= diff(all_prio_sort_v);
	k_error								= find(diff_all_prio_sort_v<1,1);
	if ~isempty(k_error)
		k1				= k_error;
		k2				= k_error+1;
		iobj1			= all_iobj_sort_v(k1);
		iobj2			= all_iobj_sort_v(k2);
		if iobj1>iobj2
			k1			= k_error+1;
			k2			= k_error;
		end
		errortext	= sprintf([...
			'Error:\n',...
			'Invalid values of the project parameters in\n',...
			'row %s, column %s and\n',...
			'row %s, column %s:\n',...
			'%s = %g\n',...
			'%s = %g\n',...
			'The values must be unique.'],...
			all_rowno_sort_c{k1,1},...
			varname_dataset_no,...
			all_rowno_sort_c{k2,1},...
			varname_dataset_no,...
			all_varname_sort_c{k1,1},all_prio_sort_v(k1,1),...
			all_varname_sort_c{k2,1},all_prio_sort_v(k2,1));
		return
	end
























	return

	% work in progress !!!!!!!!!!!!!!!!!!!!


	%------------------------------------------------------------------------------------------------------------------
	% ToDo
	% Sicherheitsabfragen:
	% -	Abgleich der Projektparameter mit Soll-Projektparametern (nicht die Werte), damit sichergestellt ist,
	%		dass alle erforderlichen Parameter enthalten sind.
	%		dass alle Parameter das richtige Format haben (S N C)
	%		dass die Werte gültig sind
	% -	Die minimale Objektbreite darf nicht größer sein als die minimale Linienbreite.
	% -	Weitere Sicherheitsabfragen systematisch einbauen
	% -	prüfen, ob bei gleichen RGB-codes auch die Farbprioriäten und PP.color.spec gleich sind und umgekehrt.
	%		sonst funktioniert das Zusammenfassen der Polygone nicht
	% -	Polygone mit gleicher Höhe, Objekt- und Farbpriorität (entspr. auch Farbe) werden zu einem Polygon vereint.
	%		Bei gleichen Objektprioritäten, aber ungleicher Höhe eine Fehlermeldung ausgeben!
	%		Bei gleichen Objektprioritäten, aber ungleicher Farbprioriät eine Warnung ausgeben (oder Fehler?).
	%		(nur wenn display=1 gesetzt ist)
	% -	readtable: spreadsheetImportOptions benutzen, um den Namen des Tabellenblatts vorgeben zu können
	% -	color-Nummer=0 ist zulässig
	%		PP.color.prio<=0 ist nicht zulässig, da dies im Programm spezielle Bedeutungen hat:
	%		PP.color.prio soll >0 sein
	% -	PP.colorspec(icolspec).dz_margin muss >0 sein
	% -	Die Color-Nummer 1 wird grundsätzlich als Grundfarbe der Kachel verwendet.
	%		Die Priorität der Color-Nummer 1 muss =0 sein!
	% -	Prioritäten dürfen nur ganzzahlig sein, weil die unterschiedlichen Höhen von Text/Hintergrund oder bei
	%		Symbolen mit Nachkommastellen realisiert werden, z. B. bei Texten:
	%		Schrift:			ud_obj.prio = PP.obj(iobj).textpar.prio;
	%		Hintergrund:	ud_bgd.prio = PP.obj(iobj).textpar.prio-0.25;
	% -	PP.obj darf nur eine Spalte haben
	%		PP.defobj darf nur eine Spalte und nur eine Zeile haben
	% -	project.version_no abfragen
	% -	PP.obj(iobj).tag_incl.k
	%		PP.obj(iobj).tag_incl.v
	%		Die Eingabe eines values ohne key ist nicht zulässig, da die Funktion osmfilter.exe dies nicht vorsieht.
	% -	Es darf nicht zweimal denselben Eintrag geben
	% -   Fehlermeldung wenn die maximale Objektprio größer als der Offset (PP.general.textsymb_prio_offset) ist.

	%------------------------------------------------------------------------------------------------------------------




	% Legend elements:
	for r=1:size(pp.legend.element,1)
		for c=1:size(pp.legend.element,2)
			i		= 0;
			data	= struct(i,1);

			% legsymb_objno now is a cell array !!!!!!!!!!!!
			% Example: PP.legend.element(12,1).legsymb_objno={[31 32 33]}

			i=i+1; data(i,1).fieldname='legsymb_objno';               data(i,1).type='ob'; data(i,1).min=0; data(i,1).max=iobj_max;
			i=i+1; data(i,1).fieldname='legsymb_mansel_color_no_sym'; data(i,1).type='co'; data(i,1).min=0; data(i,1).max=colno_max;
			i=i+1; data(i,1).fieldname='legsymb_mansel_color_no_bgd'; data(i,1).type='co'; data(i,1).min=0; data(i,1).max=colno_max;
			i=i+1; data(i,1).fieldname='text_color_no_letters';       data(i,1).type='co'; data(i,1).min=0; data(i,1).max=colno_max;
			i=i+1; data(i,1).fieldname='text_color_no_background';    data(i,1).type='co'; data(i,1).min=0; data(i,1).max=colno_max;
			i=i+1; data(i,1).fieldname='text_charstyle_no';           data(i,1).type='ch'; data(i,1).min=0; data(i,1).max=chstno_max;

			% Object number:
			for i=1:size(data,1)
				iobj	= pp.legend.element(r,c).(data(i,1).fieldname);
				if iobj~=0
					isinvalid_value	= false;
					if (iobj<0)||(iobj>iobj_max)||(round(iobj)~=iobj)
						isinvalid_value	= true;
					else
						switch data(i,1).type
							case 'ob'
								if isempty(pp.obj(iobj).display)
									isinvalid_value	= true;
								end
							case 'co'
								if isempty(pp.color(iobj).display)
									isinvalid_value	= true;
								end
							case 'ch'
								if isempty(pp.obj(iobj).display)
									isinvalid_value	= true;
								end
						end
					end
					if isinvalid_value
						errortext	= sprintf([...
							'Error:\n',...
							'Invalid value of the project parameter in\n',...
							'row %1.0f, column %s:\n',...
							'pp.legend.element(%1.0f,%1.0f).legsymb_objno\n',...
							'(%s)\n',...
							'Current value: %g\n',...
							'Maximum value: %g'],...
							pp.TABLE_ROWNO.legend.element(r,c).legsymb_objno,...
							varname_dataset_no,...
							r,...
							c,...
							pp.DESCRIPTION.legend{1,1}.element{r,c}.legsymb_objno{1,1},...
							iobj,...
							iobj_max);
						return
					end
				end
			end

			% 		% Object number:
			% 		iobj			= pp.legend.element(r,c).legsymb_objno;
			% 		if iobj~=0
			% 			isinvalid_value	= false;
			% 			if (iobj<0)||(iobj>iobj_max)||(round(iobj)~=iobj)
			% 				isinvalid_value	= true;
			% 			else
			% 				if isempty(pp.obj(iobj).display)
			% 					isinvalid_value	= true;
			% 				end
			% 			end
			% 			if isinvalid_value
			% 				errortext	= sprintf([...
			% 					'Error:\n',...
			% 					'Invalid value of the project parameter in\n',...
			% 					'row %1.0f, column %s:\n',...
			% 					'pp.legend.element(%1.0f,%1.0f).legsymb_objno\n',...
			% 					'(%s)\n',...
			% 					'Current value: %g\n',...
			% 					'Maximum value: %g'],...
			% 					pp.TABLE_ROWNO.legend.element(r,c).legsymb_objno,...
			% 					varname_dataset_no,...
			% 					r,...
			% 					c,...
			% 					pp.DESCRIPTION.legend{1,1}.element{r,c}.legsymb_objno{1,1},...
			% 					iobj,...
			% 					iobj_max);
			% 				return
			% 			end
			% 		end

			% legend	N	1	1	mapscalebar_color_no


		end
	end

catch ME
	errormessage('',ME);
end

