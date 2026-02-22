function [km1,k,kp1]=find_sorted(v,n,kmax)
% v		in ascending order sorted vector of numbers
% n		Number whose position in vector v is searched for
% kmax	number of elements in v
% km1		scalar     / empty:	index in v of the largest element <n
% k		Nx1 vector / empty:	all indices in v of elements =n
% kp1		scalar     / empty:	index in v of the smallest element >n

try
	
	% Testing:
	if nargin==0
		testcase		= 3;
		switch testcase
			case 1
				%        1 2 3 4 5 6 7 8 9 10 11
				v		= [1 2 3 4 4 4 4 5 6  7  8]';
				n		= 8.5;
			case 2
				v		= 5;
				n		= 6;
			case 3
				%        1 2
				v		= [1 2]';
				n		= 2.5;
		end
		kmax	= size(v,1);
	end
	
	% Initializations:
	km1	= [];
	k		= [];
	kp1	= [];
	
	if kmax==1
		if n<v(1)
			kp1	= 1;
		elseif n>v(1)
			km1	= 1;
		else
			k		= 1;
		end
		
	elseif kmax>1
		
		% Lower limit km1:
		k1		= 1;
		k2		= kmax;
		while isempty(km1)
			kcenter	= floor((k1+k2)/2);
			if n>v(kcenter)
				k1		= kcenter;
			else
				k2		= kcenter;
			end
			if k2-k1<=1
				if v(k1)<n
					if v(k2)<n
						km1	= k2;
					else
						km1	= k1;
					end
				else
					break
				end
			end
			if nargin==0
				fprintf(1,'Lower: k1=%g   k2=%g\n',k1,k2);
			end
		end
		
		% Upper limit kp1:
		k1		= 1;
		k2		= kmax;
		while isempty(kp1)
			kcenter	= floor((k1+k2)/2);
			if n>=v(kcenter)
				k1		= kcenter;
			else
				k2		= kcenter;
			end
			if k2-k1<=1
				if v(k2)>n
					if v(k1)>n
						kp1	= k1;
					else
						kp1	= k2;
					end
				else
					break
				end
			end
			if nargin==0
				fprintf(1,'Upper: k1=%g   k2=%g\n',k1,k2);
			end
		end
		
		% Assign k:
		if isempty(km1)&&isempty(kp1)
			errormessage;
		elseif isempty(km1)
			k		= (1:(kp1-1))';
		elseif isempty(kp1)
			k		= ((km1+1):kmax)';
		else
			k		= ((km1+1):(kp1-1))';
		end
		
	end
	
	if nargin==0
		km1
		k
		kp1
	end
	
catch ME
	errormessage('',ME);
end
