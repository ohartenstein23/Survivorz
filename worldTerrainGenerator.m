percentWater = 0.50; # Approximate percent of polygons to make water by elevation
#cdf = 0.5 * (1 + erf((x - mean) / std));
waterThreshold = erfinv(2 * percentWater - 1) * std(elevationList) + mean(elevationList);
percentPolar = 1 / 16; # Percent of lattitudes remaining beyond extra ones to make poles
maxAltitude = 5000; # Approximately in meters
# T = 59 - .00356 * h model of temp. (F) as a function of height (ft.)
# xcom terains by altitude are 0 (high vegetation) to 5 (mountain)
# 6, 10, 11 are forest/jungle, 7 and 8 desert, 9 is icecap, 12 is ice/water

# First pass through terrain data - assign 0-5, 9 by elevation
# and set -1 for below sea level
snowLevel = 3000; # assume > 3000m -> snow
terrainData = (elevationList - waterThreshold) / (max(elevationList) - waterThreshold) * maxAltitude;
terrainData(find(terrainData < 0)) = -1;
terrainData(find((terrainData >= 0) & (terrainData <= snowLevel))) = floor(terrainData(find((terrainData >= 0) & (terrainData <= snowLevel))) / snowLevel * 5.99);
terrainData(find(terrainData > snowLevel)) = 9;

# Output terrain data attached to polygons
outputFile = fopen("Ruleset/globe.rul", "w");
fdisp(outputFile, "globe:");
fdisp(outputFile, "  polygons:");
for m = 1:length(terrainData)
  if (terrainData(m) == -1)
    continue;
  endif
  fdisp(outputFile, ["    - - ", num2str(terrainData(m))]);
  scaledPolygon = polygonList{m};
  scaledPolygon(:, 1) = (scaledPolygon(:, 1) - 1) / (size(worldData)(2) - 1) * 360;
  scaledPolygon(:, 2) = (scaledPolygon(:, 2) - centerPoint(2)) / (size(worldData)(1)) * 180;
  for n = scaledPolygon'(:)'
    fdisp(outputFile, ["      - ", num2str(n, "%3.3f")]);
  endfor
endfor

fclose(outputFile);

#terrainIndex =
#
#  -1   1
#   0   2
#   1   3
#   2   4
#   3   5
#   4   6
#   5   7
#   9   8
terrainIndex  = [unique(terrainData), (1:length(unique(terrainData)))'];
terrainColors = {"blue", "cyan", "cyan", "green", "green", "yellow", "yellow", "white"};
clf;
for m = 1:length(polygonList)
  patch(polygonList{m}(:, 1), polygonList{m}(:, 2), terrainColors{terrainIndex(:, 2)(find(terrainData(m) == terrainIndex(:, 1)))})
endfor