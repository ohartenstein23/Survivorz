function createRegionFromTexture(globeFile, textures, region, outputTexture)
  
fileToRead = fopen(globeFile);
intersections = {};
currentLine = 0;
currentNode = "";
cellIndex = 0;

while(currentLine != -1)
  currentLine = fgetl(fileToRead);
  dashIndex = regexp(currentLine, '\-');
  if (length(dashIndex) == 0)
     currentNode = currentLine;
     cellIndex = 0;
  elseif (dashIndex(1) == 5)
     cellIndex++;
     if (strcmp(currentNode, "  polygons:"))
       if (length(intersections) < cellIndex)
         intersections{cellIndex} = [];
       endif
       intersections{cellIndex} = [intersections{cellIndex}; str2num(currentLine(dashIndex(2)+2:end))];
     endif
  elseif (dashIndex(1) == 7)
     if (strcmp(currentNode, "  polygons:"))
       if (length(intersections) < cellIndex)
         intersections{cellIndex} = [];
       endif
       intersections{cellIndex} = [intersections{cellIndex}; str2num(currentLine(dashIndex(1)+2:end))];
     endif
  endif
endwhile

fclose(fileToRead);

fileToWrite = fopen("./createdRegion.txt", "w");
for (m = 1:length(intersections))
  currentIntersection = intersections{m};
  if (!any(currentIntersection(1) == textures) && length(textures) != 0)
    continue;
  else
    lon = currentIntersection(2:2:end-1);
    lat = currentIntersection(3:2:end);
    if (any(lon < 90) && any(lon > 270) && (length(find((lon > 270) || (lon < 90))) == length(lon)))
      lon(find(lon<90)) = lon(find(lon<90))+360;
    endif
    meanLon = mod(mean(lon), 360);
    meanLat = mean(lat);
    if ((length(region) == 4) && (meanLon >= region(1)) && (meanLon <= region(2)) && (meanLat >= region(3)) && (meanLat<=region(4)));
      fdisp(fileToWrite, ["        - [", num2str(meanLon), ", ", num2str(meanLon), ", ", num2str(meanLat), ", ", num2str(meanLat), ", ", num2str(outputTexture), "]"]);
    elseif (length(region) == 0)
      fdisp(fileToWrite, ["        - [", num2str(meanLon), ", ", num2str(meanLon), ", ", num2str(meanLat), ", ", num2str(meanLat), ", ", num2str(outputTexture), "]"]);
    endif
  endif
endfor

fclose(fileToWrite);

endfunction