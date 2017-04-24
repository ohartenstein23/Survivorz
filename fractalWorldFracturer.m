pkg load image
pkg load geometry

worldData = imread("worldgen_greyscale_size500.gif");
nPolys = 100;
# Start by evenly distributing random points over a sphere, scaling to match image index size
distPoints = linspace(0, 1, round(sqrt(nPolys)));
pointSpacing = diff(distPoints)(1);
[rr cc] = meshgrid(distPoints, distPoints);

randRows = abs(acos(2 * (rr(:) + normrnd(0, 0.15* pointSpacing, length(rr(:)), 1)) - 1) * (size(worldData)(1) - 1) / pi) + 1;
randCols = ((cc(:) + normrnd(0, 0.15* pointSpacing, length(cc(:)), 1)) * (size(worldData)(2) - 1)) + 1;

[worldVertices worldPolygons] = voronoin([randCols, randRows]);
[xx yy] = meshgrid(1:size(worldData)(2), 1:size(worldData)(1));
yy = flipud(yy);

centerPoint = [(size(worldData)(2) + 1) / 2, (size(worldData)(1) + 1) / 2];

polygonList = {};
polygonCenters = [];
elevationList = [];
for m = 1:length(worldPolygons);

  if !(any(worldPolygons{m}))
    continue;
  endif

	polyVertices = [worldVertices(worldPolygons{m}, 1), worldVertices(worldPolygons{m}, 2)];
	[infIndex1 infIndex2] = find(isinf(polyVertices));
  croppedVertices = polyVertices;
	if (any(infIndex1))
    for n = 1:length(infIndex1);
      if (infIndex2(n) == 1)
        croppedVertices(infIndex1(n), infIndex2(n)) = size(worldData)(2) * 1e3 * sign(randCols(m) - centerPoint(1));
      else
        croppedVertices(infIndex1(n), infIndex2(n)) = size(worldData)(1) * 1e3 * sign(randRows(m) - centerPoint(2));
      endif
    endfor
	endif

	boundingPoints = [1, 1; 1, size(worldData)(1); size(worldData)(2), size(worldData)(1); size(worldData)(2), 1];

	boundedVertices = clipPolygon(croppedVertices, boundingPoints, 1);
  
  globePolygons = [];
  polyList = [];
  if (size(boundedVertices)(1) > 4)
    centerVertex = polygonCentroid(boundedVertices);
    for (n = 1:size(boundedVertices)(1) - 1)
      globePolygons = cat(3, globePolygons, [boundedVertices(n, :); boundedVertices(n+1, :); centerVertex]);
      polyList = [polyList, n];
    endfor
  else
    globePolygons = boundedVertices;
    polyList = 1;
  endif
      
  for n = polyList;
    polyIndex = find(inpolygon(xx(:), yy(:), globePolygons(:, 1, n), globePolygons(:, 2, n)));
    elevationScore = median(worldData(polyIndex));
    
    polygonList = [polygonList; {globePolygons(:, :, n)}];
    polygonCenters = [polygonCenters; polygonCentroid(globePolygons(:, :, n))];
    elevationList = [elevationList; double(elevationScore)];
  endfor

endfor