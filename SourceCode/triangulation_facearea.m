function facearea=triangulation_facearea(P,CL)
% Area of all triangles defined by the connectivity list.

% Testing:
if nargin==0
	P		= [...
		0 0 0;...		% 1
		0 0 0;...		% 2
		1 0 0;...		% 3
		1 1 0];			% 4
	CL	= [...
		1 3 4;...
		1 2 4];
end

kmax			= size(CL,1);
if kmax>=1
	F				= zeros(kmax,3);		% All face vectors
	mag_F			= zeros(kmax,1);		% All face areas
	for k=1:kmax
		F(k,:)				= cross(...
			P(CL(k,2),:)-P(CL(k,1),:),...
			P(CL(k,3),:)-P(CL(k,1),:))/2;
		mag_F(k,1)			= sqrt(sum(F(k,:).^2,2));
	end
	facearea		= sum(mag_F);
else
	facearea		= 0;
end


