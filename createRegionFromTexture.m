function createRegionFromTexture(globeFile, textures, outputTexture)
  
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
  if (!any(currentIntersection(1) == textures))
    continue;
  else
    lon = currentIntersection(2:2:end-1);
    lat = currentIntersection(3:2:end);
    if (any(lon < 90) && any(lon > 270) && (length(find((lon > 270) || (lon < 90))) == length(lon)))
      lon(find(lon<90)) = lon(find(lon<90))+360;
    endif
    fdisp(fileToWrite, ["        - [", num2str(mod(mean(lon), 360)), ", ", num2str(mod(mean(lon), 360)), ", ", num2str(mean(lat)), ", ", num2str(mean(lat)), ", ", num2str(outputTexture), "]"]);
  endif
endfor

fclose(fileToWrite);

endfunction