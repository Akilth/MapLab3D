function T_index=verify_pp_create_T_index(T)
% Indexing of the project parameters table:
% Creates of every field name a logical vector.
% The vector element is true in all rows in which the field name appears.
% Example:
% T_index.f1 =
%   struct with fields:
%        project: [3143×1 logical]
%        general: [3143×1 logical]
%         legend: [3143×1 logical]
%          frame: [3143×1 logical]
%     testsample: [3143×1 logical]
%          color: [3143×1 logical]
%      colorspec: [3143×1 logical]
%      charstyle: [3143×1 logical]
%         defobj: [3143×1 logical]
%            obj: [3143×1 logical]

try

	T_index.f1						= struct;
	T_index.f2						= struct;
	T_index.f3						= struct;
	T_index.f4						= struct;
	T_index.f1.emptyfields		= false(height(T),1);
	T_index.f2.emptyfields		= false(height(T),1);
	T_index.f3.emptyfields		= false(height(T),1);
	T_index.f4.emptyfields		= false(height(T),1);
	T_index.snmc1					= struct;
	T_index.snmc2					= struct;
	T_index.snmc3					= struct;
	T_index.snmc4					= struct;
	T_index.snmc1.emptyfields	= false(height(T),1);
	T_index.snmc2.emptyfields	= false(height(T),1);
	T_index.snmc3.emptyfields	= false(height(T),1);
	T_index.snmc4.emptyfields	= false(height(T),1);
	T_index.r1						= T.R1;			T_index.r1(isnan(T_index.r1))	= 1;
	T_index.r2						= T.R2;			T_index.r2(isnan(T_index.r2))	= 1;
	T_index.r3						= T.R3;			T_index.r3(isnan(T_index.r3))	= 1;
	T_index.r4						= T.R4;			T_index.r4(isnan(T_index.r4))	= 1;
	T_index.c1						= T.C1;			T_index.c1(isnan(T_index.c1))	= 1;
	T_index.c2						= T.C2;			T_index.c2(isnan(T_index.c2))	= 1;
	T_index.c3						= T.C3;			T_index.c3(isnan(T_index.c3))	= 1;
	T_index.c4						= T.C4;			T_index.c4(isnan(T_index.c4))	= 1;

	% Create cell arrays (faster than working with tables):
	f1					= T.FIELD1(:);
	f2					= T.FIELD2(:);
	f3					= T.FIELD3(:);
	f4					= T.FIELD4(:);
	snmc1				= T.SNMC1(:);
	snmc2				= T.SNMC2(:);
	snmc3				= T.SNMC3(:);
	snmc4				= T.SNMC4(:);

	for r=1:height(T)

		if ~isempty(f1{r,1})
			if ~isfield(T_index.f1,f1{r,1})
				T_index.f1.(f1{r,1})			= false(height(T),1);
				T_index.f1.(f1{r,1})(r,1)	= true;
			else
				T_index.f1.(f1{r,1})(r,1)	= true;
			end
		else
			T_index.f1.emptyfields(r,1)	= true;
		end
		if ~isempty(f2{r,1})
			if ~isfield(T_index.f2,f2{r,1})
				T_index.f2.(f2{r,1})			= false(height(T),1);
				T_index.f2.(f2{r,1})(r,1)	= true;
			else
				T_index.f2.(f2{r,1})(r,1)	= true;
			end
		else
			T_index.f2.emptyfields(r,1)	= true;
		end
		if ~isempty(f3{r,1})
			if ~isfield(T_index.f3,f3{r,1})
				T_index.f3.(f3{r,1})			= false(height(T),1);
				T_index.f3.(f3{r,1})(r,1)	= true;
			else
				T_index.f3.(f3{r,1})(r,1)	= true;
			end
		else
			T_index.f3.emptyfields(r,1)	= true;
		end
		if ~isempty(f4{r,1})
			if ~isfield(T_index.f4,f4{r,1})
				T_index.f4.(f4{r,1})			= false(height(T),1);
				T_index.f4.(f4{r,1})(r,1)	= true;
			else
				T_index.f4.(f4{r,1})(r,1)	= true;
			end
		else
			T_index.f4.emptyfields(r,1)	= true;
		end

		if ~isempty(snmc1{r,1})
			if ~isfield(T_index.snmc1,snmc1{r,1})
				T_index.snmc1.(snmc1{r,1})		= false(height(T),1);
				T_index.snmc1.(snmc1{r,1})(r,1)	= true;
			else
				T_index.snmc1.(snmc1{r,1})(r,1)	= true;
			end
		else
			T_index.snmc1.emptyfields(r,1)	= true;
		end
		if ~isempty(snmc2{r,1})
			if ~isfield(T_index.snmc2,snmc2{r,1})
				T_index.snmc2.(snmc2{r,1})		= false(height(T),1);
				T_index.snmc2.(snmc2{r,1})(r,1)	= true;
			else
				T_index.snmc2.(snmc2{r,1})(r,1)	= true;
			end
		else
			T_index.snmc2.emptyfields(r,1)	= true;
		end
		if ~isempty(snmc3{r,1})
			if ~isfield(T_index.snmc3,snmc3{r,1})
				T_index.snmc3.(snmc3{r,1})		= false(height(T),1);
				T_index.snmc3.(snmc3{r,1})(r,1)	= true;
			else
				T_index.snmc3.(snmc3{r,1})(r,1)	= true;
			end
		else
			T_index.snmc3.emptyfields(r,1)	= true;
		end
		if ~isempty(snmc4{r,1})
			if ~isfield(T_index.snmc4,snmc4{r,1})
				T_index.snmc4.(snmc4{r,1})		= false(height(T),1);
				T_index.snmc4.(snmc4{r,1})(r,1)	= true;
			else
				T_index.snmc4.(snmc4{r,1})(r,1)	= true;
			end
		else
			T_index.snmc4.emptyfields(r,1)	= true;
		end

	end

catch ME
	errormessage('',ME);
end

