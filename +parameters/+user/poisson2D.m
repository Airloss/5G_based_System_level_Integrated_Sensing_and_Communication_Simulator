classdef poisson2D < parameters.user.ueParameters
    %POISSON2D 
    %  UE parameters class with two-dimensional (2D) poisson distribution
    
    properties
        % distribution radius, the distribution region
        % is defined as a regular hexagon region (cell)
        %[1x1] double
        radius

        % (x,y) coordinate of the distribution center
        %[2x1] double
        centerCoord
    end

    properties (Dependent = true)
        % UE positions, (x, y, z) coordinates
        %[n x 3] matrix
        position (:,3) double
    end
    
    methods
        function obj = poisson2D()
            %POISSON2D 
            % UEs with 2D poisson distribution positions
            obj@parameters.user.ueParameters
        end
        
        function pos = get.position(obj)
            % Get the distributed positions
            % maxium number of UEs
            maximumUEs = obj.numUEs;

            % 2D-Poisson distribution coordinates
            lambda = maximumUEs / (pi * obj.radius^2);
            numPoints = poissrnd(lambda * pi * obj.radius^2);
            points = obj.generatePoissonPoints(numPoints);
            
            % Adjust the number of points to match numUEs
            if numPoints > maximumUEs
                % If the generated number of points is greater than numUEs,
                % randomly select numUEs points from the generated points
                selectedIndices = randperm(numPoints, maximumUEs);
                points = points(selectedIndices, :);
            elseif numPoints < maximumUEs
                % If the generated number of points is less than numUEs,
                % generate additional points to match numUEs
                additionalPoints = obj.generatePoissonPoints(maximumUEs - numPoints);
                points = [points; additionalPoints];
            end
            
            % Convert point coordinates to positions 
            % relative to the center point
            pos = points + obj.centerCoord;
            % Add height coordinate
            pos = [pos obj.height * ones(size(pos, 1), 1)];
        end
    end

    methods (Access = private)
        function points = generatePoissonPoints(obj, numPoints)
            % Generate 2D Poisson distributed point 
            % coordinates within a regular hexagonal region
            
            % Calculate the coordinates of the vertices of a regular hexagon
            angles = linspace(0, 2*pi, 7);
            hexagonVertices = obj.radius * [cos(angles); sin(angles)];
            
            % Generating point labels for a Poisson distribution
            points = [];
            while size(points, 1) < numPoints
                newPoints = obj.radius * (rand(numPoints, 2) - 0.5);
                
                % Determining if a point is inside a regular hexagon
                inHexagon = inpolygon(newPoints(:, 1), newPoints(:, 2), hexagonVertices(1, :), hexagonVertices(2, :));
                
                % Adding points that are inside a regular hexagon to the result
                points = [points; newPoints(inHexagon, :)];
            end
            
            % Selecting a specified number of points
            points = points(1:numPoints, :);
        end
    end
end

