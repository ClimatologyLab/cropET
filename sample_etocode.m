% modify this if you want more monthly in the mix, there can be high ETo in
% spring as well so it might be better to consider something like
% March-August or March-Sep ETo
lat1=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/summaries/metdata_pet_monthlyTimeSeries_Jan.nc#fillmismatch','lat');
lon1=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/summaries/metdata_pet_monthlyTimeSeries_Jan.nc#fillmismatch','lon');

% just import bounding box

flat=find(lat1>=34 & lat1<=42);
flon=find(lon1>-124.5 & lon1<=-118);

lon=lon(flon);
lat=lat(flat);
[lon,lat]=meshgrid(lon,lat);

mm={'Jun';'Jul';'Aug'}
for month=1:3
n=['http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/summaries/metdata_pet_monthlyTimeSeries_',char(mm(month)),'.nc#fillmismatch'];
eto(:,:,:,month)=ncread(n,'potential_evapotranspiration',[flon(1) flat(1) 1],[length(flon) length(flat) Inf],[1 1 1]);
end

eto=permute(eto,[2 1 4 3]);

% if you want you can read in monthly precipitation or other variables in a
% similar manner

% if you want to clip by county, download + extract this shapefile
% https://data.ca.gov/dataset/ca-geographic-boundaries/resource/b0007416-a325-4777-9295-368ea6b710e6

m=shaperead('CA_Counties_TIGER2016')
l=shapeinfo('CA_Counties_TIGER2016')
p1=l.CoordinateReferenceSystem;
for i=1:58
    nn=cell2mat(m.ncst(i,1));
    mout(i).lon=nn(:,1);
    mout(i).lat=nn(:,2);
    mout(i).name=m.dbfdata(i,1);
end

% for example #28 is Yolo county

a=inpolygon(mout(28).lon,mout(28).lat,lon,lat);
a=find(a==1); % this just identifies indice of pixels in Yolo county

eto=permute(eto,[3 4 1 2]);

yoloeto=squeeze(nanmean(eto(:,:,a),3));

