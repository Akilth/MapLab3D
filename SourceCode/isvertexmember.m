function [i,na,nb] = isvertexmember(va,vb,tol)
% Returns an array containing logical 1 (true) where the vertices in va are found in vb.
% Elsewhere, the array contains logical 0 (false).
% i			has the same number of rows as va.
% na			number of occurrences of to vb identical vertices in va, corresponding vector to va (optional)
% nb			number of occurrences of to va identical vertices in vb, corresponding vector to vb (optional)
% va, vb		N-by-2 matrices, where N is the number of vertices.
%				va(:,1), vb(:,1)		x-values
%				va(:,2), vb(:,2)		y-values
%				va(:,3), vb(:,3)		z-values (optional)
% tol			Tolerance
% Syntax:
% 1)			i         = isvertexmember(va,vb,tol)
% 2)			[i,na,nb] = isvertexmember(va,vb,tol)

try

	% Test:
	if nargin==0
		clc
		test	= 2;
		switch test
			case 1
				va		= [...
					1 1;...
					2 2;...
					3 3;...
					nan nan;...
					4 4;...
					5 5;...
					nan nan;...
					6 6;...
					7 7;...
					8 8;...
					9 9];
				vb		= [...
					1 2;...
					2 2;...
					nan nan;...
					3 2;...
					5 5];
			case 2
				va		= [...
					1 1 1;...
					2 2 2;...
					2 2 2;...
					3 3 3;...
					4 4 4;...
					5 5 5;...
					6 6 6];
				vb		= [...
					1 2 3;...
					2 2 2;...
					4 5 6;...
					2 2 2;...
					7 8 9;...
					2 2 2;...
					9 8 7;...
					2 2 2;...
					6 5 4;...
					5 5 5];
			case 3
				dim		= 3;
				nvert_a	= 2e4;
				nvert_b	= round(nvert_a*0.7);
				va(1:nvert_a,1)	= (1:nvert_a)';
				va(1:nvert_a,2)	= ones(nvert_a,1)*3;		% va: y=3
				vb(1:nvert_b,1)	= ones(nvert_b,1)*3;		% vb: x=1
				vb(1:nvert_b,2)	= mod((1:nvert_b)',5);
				if dim==3
					va(1:nvert_a,3)	= zeros(nvert_a,1);
					vb(1:nvert_b,3)	= zeros(nvert_b,1);
				end
		end
		tol	= 1e-8;
	end

	nab_max	= 3e3;
	% dim		nab_max	RAM-usage		size of VAX
	% 2		5e3		+ 0.80 GB		 5000x 5000 elements, 200MB (also VAY, VBX, VBY)
	% 2		1e4		+ 3.20 GB		10000x10000 elements, 800MB (also VAY, VBX, VBY)
	% 3		1e3		+ 0.00 GB		 1000x 1000 elements,   8MB (also VAY, VAZ, VBX, VBY, VBZ)
	% 3		2e3		+ 0.19 GB		 2000x 2000 elements,  32MB (also VAY, VAZ, VBX, VBY, VBZ)
	% 3		3e3		+ 0.43 GB		 3000x 3000 elements,  72MB (also VAY, VAZ, VBX, VBY, VBZ)
	% 3		5e3		+ 1.20 GB		 5000x 5000 elements, 200MB (also VAY, VAZ, VBX, VBY, VBZ)

	kamax		= max(1,ceil(size(va,1)/nab_max));
	kbmax		= max(1,ceil(size(vb,1)/nab_max));
	i			= false(size(va,1),1);
	if (nargout>=3)||(nargin==0)
		na		= zeros(size(va,1),1);
		nb		= zeros(size(vb,1),1);
	else
		na		= [];
		nb		= [];
	end
	for ka=1:kamax
		kaoff	= (ka-1)*nab_max;
		ia_v	= ((kaoff+1):min((kaoff+nab_max),size(va,1)))';
		for kb=1:kbmax
			kboff	= (kb-1)*nab_max;
			ib_v	= ((kboff+1):min((kboff+nab_max),size(vb,1)))';

			if isequal(size(va,2),2)&&isequal(size(vb,2),2)
				vax				= va(ia_v,1);
				vay				= va(ia_v,2);
				vbx				= vb(ib_v,1);
				vby				= vb(ib_v,2);
				[VAX,VBX]		= meshgrid(vax,vbx);
				[VAY,VBY]		= meshgrid(vay,vby);
				[row,col]		= find((abs(VAX-VBX)<tol)&(abs(VAY-VBY)<tol));
				if ~isempty(col)
					i(col+kaoff)	= true;
					if (nargout>=3)||(nargin==0)
						[ra,ca]			= meshgrid(col,col);
						na(col+kaoff)	= na(col+kaoff)+sum(ra==ca,2);
						[rb,cb]			= meshgrid(row,row);
						nb(row+kboff)	= nb(row+kboff)+sum(rb==cb,2);
					end
				end

			elseif isequal(size(va,2),3)&&isequal(size(vb,2),3)
				vax				= va(ia_v,1);
				vay				= va(ia_v,2);
				vaz				= va(ia_v,3);
				vbx				= vb(ib_v,1);
				vby				= vb(ib_v,2);
				vbz				= vb(ib_v,3);
				[VAX,VBX]		= meshgrid(vax,vbx);
				[VAY,VBY]		= meshgrid(vay,vby);
				[VAZ,VBZ]		= meshgrid(vaz,vbz);
				[row,col]		= find((abs(VAX-VBX)<tol)&(abs(VAY-VBY)<tol)&(abs(VAZ-VBZ)<tol));
				if ~isempty(col)
					i(col+kaoff)	= true;
					if (nargout>=3)||(nargin==0)
						[ra,ca]			= meshgrid(col,col);
						na(col+kaoff)	= na(col+kaoff)+sum(ra==ca,2);
						[rb,cb]			= meshgrid(row,row);
						nb(row+kboff)	= nb(row+kboff)+sum(rb==cb,2);
					end
				end

			else
				error('Error: wrong dimensions of va and vb:\nsize(va,2)= %g\nsize(vb,2)= %g\n',size(va,2),size(vb,2));
			end
			% Test
			% if (nargin==0)&&(ka==1)&&(kb==1)
			% 	pause(0.001)
			% 	whos
			% 	pause(3);
			% end
		end
	end

	% % Test:
	% if nargin==0
	%  va_na_i=[va na i]
	%  vb_nb	= [vb nb]
	% 	setbreakpoint	= 1;
	% end

catch ME
	errormessage('',ME);
end

