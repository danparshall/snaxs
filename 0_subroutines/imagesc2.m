function h = imagesc2 ( Q_array, E_array, img_data , climits)
% h = imagesc2 ( Q_array, E_array, img_data )
% 	a wrapper for imagesc, with some formatting going on for nans
% 	from Bill Cheatham, at 
%	http://stackoverflow.com/questions/14933039/matlab-imagesc-plotting-nan-values


% plotting data. Removing and scaling axes (this is for image plotting)
if ~exist('climits')
	h = imagesc(Q_array, E_array, img_data);
else
	h = imagesc(Q_array, E_array, img_data, climits);
end

axis image off

% setting alpha values
if ndims( img_data ) == 2
  set(h, 'AlphaData', ~isnan(img_data))
elseif ndims( img_data ) == 3
  set(h, 'AlphaData', ~isnan(img_data(:, :, 1)))
end

if nargout < 1
  clear h
end

