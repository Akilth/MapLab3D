function [CL_test,CL_new,F_test,F_new,E_test]=stlrepair_close_hole_recursion(...
	T,...
	Esort_without_Ecline,...
	CL_test_0,...
	CL_new,...
	F_test_0,...
	F_new,...
	E_test_0,...
	ip_cline,...
	E_cline,...
	height_CL,...
	debugdata)
% This function creates a connectivity list of triangles within a closed line of open edges
% (edges that are only connected to one triangle each).
% T							triangulation data
% Esort_without_Ecline	triangulation edges: the elements of each row must be sorted
%															and must not contain the edges of E_cline.
% CL_test_0					connectivity list: current attempt, initial value
% CL_test					connectivity list: current attempt, maybe extended
% CL_new						connectivity list: cell array of valid solutions.
% F_test_0					face normal vectors: current attempt, initial value
% F_test						face normal vectors: current attempt, maybe extended
% F_new						face normal vectors: cell array of valid solutions, corresponding to CL_new.
% E_test_0					triangulation edges: current attempt, initial value
% E_test						triangulation edges: current attempt, maybe extended
% ip_cline					vertex identification numbers between the edges E_cline
% E_cline					open edges that form a closed line: two-column matrix of vertex identification numbers
% height_CL					total number of triangles to be created

try

	debugdata.recursion_depth	= debugdata.recursion_depth+1;
	debugdata.i1(end+1,1)		= 0;
	debugdata.i2(end+1,1)		= 0;
	debugdata.imax(end+1,1)		= 0;

	if size(ip_cline,1)==3
		% There are only three points: extend the connectivity list CL_test:
		p1			= [T.Points(ip_cline(1,1),1) T.Points(ip_cline(1,1),2) T.Points(ip_cline(1,1),3)];
		p2			= [T.Points(ip_cline(2,1),1) T.Points(ip_cline(2,1),2) T.Points(ip_cline(2,1),3)];
		p3			= [T.Points(ip_cline(3,1),1) T.Points(ip_cline(3,1),2) T.Points(ip_cline(3,1),3)];
		F			= cross(p2-p1,p3-p2)/2;
		mag_F		= sqrt(sum(F.^2,2));
		if mag_F>0
			% Extend the face normal vectors:
			F_test	= [F_test_0;F];
			% Extend the triangulation edges:
			E123		= sort([...
				ip_cline(1,1) ip_cline(2,1);...
				ip_cline(2,1) ip_cline(3,1);...
				ip_cline(3,1) ip_cline(1,1)],2);
			E_test	= E_test_0;
			for i=1:3
				if ~any((E123(i,1)==E_test(:,1))&(E123(i,2)==E_test(:,2)))
					% The new edge E123(i,:) does not yet exist in E_test: add the edge E123(i,:) to E_test_0:
					E_test	= [E_test;E123(i,:)];
				end
			end
			% Extend the connectivity list:  For better comparability, sort the indices
			% so that they start with the smallest value, but do not change the order:
			if (ip_cline(1,1)<ip_cline(2,1))&&(ip_cline(1,1)<ip_cline(3,1))
				CL_test	= [CL_test_0;ip_cline(1,1) ip_cline(2,1) ip_cline(3,1)];
			elseif (ip_cline(2,1)<ip_cline(1,1))&&(ip_cline(2,1)<ip_cline(3,1))
				CL_test	= [CL_test_0;ip_cline(2,1) ip_cline(3,1) ip_cline(1,1)];
			else
				CL_test	= [CL_test_0;ip_cline(3,1) ip_cline(1,1) ip_cline(2,1)];
			end
			% If the number of triangles required is only one, the else block is not run through: Assign results directly:
			if height_CL==1
				CL_new{1,1}	= CL_test;
				F_new{1,1}	= F_test;
			end
		else
			CL_test	= CL_test_0;
			F_test	= F_test_0;
			E_test	= E_test_0;
		end

	else

		% Divide the area within the points ip_cline into two halves.
		% All possible positions of the dividing line are tested.
		% The dividing line must not run along an existing edge.
		% Example: ip_cline contains imax=7 points, the dividing line runs from point i1 to i2:
		%			i2off=0
		%	i1		i2=
		%	1		3	4	5	6
		%	2			4	5	6	7
		%	3				5	6	7
		%	4					6	7
		%	5						7
		%	6
		%	7
		imax			= size(ip_cline,1);
		for i1=1:(imax-2)							% for i1=1:(imax-2)
			if i1==1
				i2max		= imax-1;
			else
				i2max		= imax;
			end
			i2min		= i1+2;

			% Increase i2min until the 1st half no longer has an area of zero:
			i1p1r		= vindexrest(i1+1,imax);
			p1			= [T.Points(ip_cline(i1   ,1),1) T.Points(ip_cline(i1   ,1),2) T.Points(ip_cline(i1   ,1),3)];
			p2			= [T.Points(ip_cline(i1p1r,1),1) T.Points(ip_cline(i1p1r,1),2) T.Points(ip_cline(i1p1r,1),3)];
			p3			= [T.Points(ip_cline(i2min   ,1),1) T.Points(ip_cline(i2min   ,1),2) T.Points(ip_cline(i2min   ,1),3)];
			p12		= p2-p1;
			p13		= p3-p1;
			F			= cross(p12,p13)/2;
			mag_F		= sqrt(sum(F.^2,2));
			while (mag_F==0)&&(i2min<i2max)
				i2min		= i2min+1;
				p3			= [T.Points(ip_cline(i2min   ,1),1) T.Points(ip_cline(i2min   ,1),2) T.Points(ip_cline(i2min   ,1),3)];
				p13		= p3-p1;
				F			= cross(p12,p13)/2;
				mag_F		= sqrt(sum(F.^2,2));
			end
			if (i2min==i2max)&&(mag_F==0)
				% All points (i1+2)..i2max are collinear: Cancel
				CL_test	= CL_test_0;
				F_test	= F_test_0;
				E_test	= E_test_0;
				break
			end

			for i2=i2min:i2max							% for i2=(i1+2):i2max

				% 1. half: i1..i2
				i_1p		= (i1:i2)';
				ip_1p		= ip_cline(i_1p,1);
				E_1p		= [E_cline(i_1p(1:(end-1)),:);ip_cline(i2,1) ip_cline(i1,1)];
				% 2: half: i2..i1+imax
				i_2p		= vindexrest(i2:(i1+imax),imax);
				ip_2p		= ip_cline(i_2p,1);
				E_2p		= [E_cline(i_2p(1:(end-1)),:);ip_cline(i1,1) ip_cline(i2,1)];

				% debugdata.i1(end,1)		= i1;
				% debugdata.i2(end,1)		= i2;
				% debugdata.imax(end,1)	= imax;
				% % fprintf(1,'imax=% 3.0f ,  i1=% 3.0f ,  i2=% 3.0f ,  recursion_dept=% 5.0f\n',imax,i1,i2,debugdata.recursion_depth);
				% for i=1:size(debugdata.i1,1)
				% fprintf(1,'%g/%g/%g\t',debugdata.i1(i,1),debugdata.i2(i,1),debugdata.imax(i,1));
				% end
				% fprintf(1,'ip_1p=%s\tip_2p=%s',number2str(ip_1p,'%g'),number2str(ip_2p,'%g'));
				% fprintf(1,'\n');

				% ha=gca;
				% p1			= [T.Points(ip_cline(i1,1),1) T.Points(ip_cline(i1,1),2) T.Points(ip_cline(i1,1),3)];
				% p2			= [T.Points(ip_cline(i2,1),1) T.Points(ip_cline(i2,1),2) T.Points(ip_cline(i2,1),3)];
				% plot3(ha,...
				% 	[p1(1) p2(1)],...
				% 	[p1(2) p2(2)],...
				% 	[p1(3) p2(3)],'-c','LineWidth',1);
				% drawnow;

				% Extend CL_test and F_test:
				% 1st half :
				size_CLtest_0		= size(CL_test_0,1);
				[CL_test,CL_new,F_test,F_new,E_test]	= stlrepair_close_hole_recursion(...
					T,...
					Esort_without_Ecline,...
					CL_test_0,...
					CL_new,...
					F_test_0,...
					F_new,...
					E_test_0,...
					ip_1p,...		% ip_cline
					E_1p,...			% E_cline
					height_CL,...
					debugdata);
				size_CLtest_1		= size(CL_test,1);
				if size_CLtest_1>size_CLtest_0
					% The filling of the 1st half was successful:

					% 2nd half:
					[CL_test,CL_new,F_test,F_new,E_test]	= stlrepair_close_hole_recursion(...
						T,...
						Esort_without_Ecline,...
						CL_test,...
						CL_new,...
						F_test,...
						F_new,...
						E_test,...
						ip_2p,...		% ip_cline
						E_2p,...			% E_cline
						height_CL,...
						debugdata);
					size_CLtest_2		= size(CL_test,1);
					if size_CLtest_2>size_CLtest_1
						% The filling of the 2nd half was also successful:

						% Only save the result CL_test if:
						% - the area of all triangles is >0
						% - the number of triangles is equal to the required value height_CL
						% - this combination of triangles is new
						% - the new edges are not identical to the existing edges Esort_without_Ecline
						if size_CLtest_2==height_CL
							magnitude_F_test	= sqrt(sum(F_test.^2,2));
							if ~any(magnitude_F_test==0)
								% Check if this combination of triangles is new:
								CL_exists_already			= false;
								for i=1:size(CL_new,1)
									% Search all previous solutions CL_new{i,1} for the current solution CL_test:
									% Note: the order of the triangles (rows in CL_new{i,1}, CL_test) may differ.
									isequal_CLnewi_CLtest	= false(size(CL_new{i,1},1),1);
									for k1=1:size(CL_new{i,1},1)
										for k2=1:size_CLtest_2
											if isequal(CL_new{i,1}(k1,:),CL_test(k2,:))
												% The line CL_new{i,1}(k1,:) is also contained in CL_test:
												isequal_CLnewi_CLtest(k1,1)	= true;
												break
											end
										end
									end
									if ~any(~isequal_CLnewi_CLtest)
										% If isequal_CLnewi_CLtest(:,1) is completely =true: CL_test exists already:
										CL_exists_already			= true;
										break
									end
								end
								% Check if the new edges are not identical to the existing edges Esort_without_Ecline:
								E_exists_already			= false;
								for i=1:size(E_test,1)
									if any((E_test(i,1)==Esort_without_Ecline(:,1))&(E_test(i,2)==Esort_without_Ecline(:,2)))
										% The edge E_test(i,1) exists already in Esort_without_Ecline: Do not use this solution:
										E_exists_already			= true;
										% E_test
										% CL_test
										% E_test_i	= E_test(i,:)
										break
									end
								end
								% Save the result:
								if ~CL_exists_already&&~E_exists_already
									i				= size(CL_new,1)+1;
									CL_new{i,1}	= CL_test;
									F_new{i,1}	= F_test;
								end
							end
						end

					end
				end
			end
		end
	end

catch ME
	errormessage('',ME);
end

