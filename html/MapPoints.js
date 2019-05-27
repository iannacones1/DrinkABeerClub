var infowindow = null;
var map = null;

function makeMap(inBreweries)
{
    var mapOptions =
    {
        center: { lat: 39.50, lng: -98.35},
        zoom: 3
    };

    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

    setMarkers(map, inBreweries);

    infowindow = new google.maps.InfoWindow();
}

function updateInfoWindow(map, marker)
{
    var imgStr = 'https://d1c8v1qci5en44.cloudfront.net/site/brewery_logos/' + marker.img;
    if (marker.img.substring(0,4) == 'http') 
    {
        imgStr = marker.img
    }

    var contentString = '<table><tr><td>' +
        '<img src="' + imgStr +'">' +
	'</td><td><p><b>' + marker.title +'</b></p><p>' + marker.desc +'</p></td></tr></table>';

    infowindow.setContent(contentString);
    infowindow.open(map, marker);
}

function setMarkers(map, locations)
{
    for (var i = 0; i < locations.length; i++)
    {
        var brewery = locations[i];
        var myLatLng = new google.maps.LatLng(brewery[1], brewery[2]);
        var marker = new google.maps.Marker({
            position: myLatLng,
            map: map,
            title: brewery[0],
            img: brewery[3],
            desc: brewery[4]
        });

        google.maps.event.addListener(marker, 'click', function(){ updateInfoWindow(map, this); });
    }
}