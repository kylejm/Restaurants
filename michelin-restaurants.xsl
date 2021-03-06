<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">

<html> 

<head>
	<title>Restaurants</title>

	<meta name="viewport" content="width=device-width, initial-scale=1"></meta>

	<link rel="stylesheet" href="style.css" />

	<link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css"></link>
	<script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
	<script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
	<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&amp;signed_in=true"></script>

	<script type="text/javascript">

		var mainMap;
		var mainMapMarkers = new Array();

		function fitMarkersOnMainMap() {
			var bounds = new google.maps.LatLngBounds();
			mainMapMarkers.forEach(function(entry) {
				bounds.extend(entry.getPosition());
			});

			mainMap.fitBounds(bounds);
		}

		var userLocation;

		function findUsersLocation(callback) {
			navigator.geolocation.getCurrentPosition(function(position) {
				<!-- TODO: handle no geoLocation available -->
				userLocation = new google.maps.LatLng(
					position.coords.latitude,
					position.coords.longitude
				);

				if (callback != null) {
					callback();
				}
			});
		}

		function addUsersLocationToMainMap() {
			findUsersLocation(function() {
				var marker = new google.maps.Marker({
				    position: userLocation,
				    map: mainMap,
				});

				mainMapMarkers.push(marker);

				var info = new google.maps.InfoWindow({
			       content: "<b>YOU ARE HERE</b>"
			    });

				info.open(mainMap, marker);

			    google.maps.event.addListener(marker, "click", function(e) {
					info.open(mainMap, marker);
			    });

				fitMarkersOnMainMap();
			})
		}

		$(document).on("pageshow", "#map-page", function(event) {
			setTimeout(function() { 
				var options = {
					center: new google.maps.LatLng(51.508742,-0.120850),
					zoom: 13,
					mapTypeId: google.maps.MapTypeId.ROADMAP
				};

				mainMap = new google.maps.Map($(event.target).find('#map').get(0), options);

				<xsl:for-each select="michelin-restaurants/restaurant">
					var restLocation = new google.maps.LatLng(
						<xsl:value-of select="location/longitude"/>,
						<xsl:value-of select="location/latitude"/>
					);

					var marker = new google.maps.Marker({
					    position: restLocation,
					    map: mainMap,
					    clickable: true,
					});

					mainMapMarkers.push(marker);

					var info = new google.maps.InfoWindow({
				       content: "<xsl:value-of select="name"/>"
				    });

				    info.open(mainMap, marker);

				    google.maps.event.addListener(marker, "click", function(e) {
						$.mobile.changePage("#" + "<xsl:value-of select="id"/>", {
							transition: "slide"
						});
				    });
				</xsl:for-each>

				fitMarkersOnMainMap();
			}, 5);
		});

		var displayedMap;
		var directionsPanel;
		var currentLocation;

		<!-- Maps for each page -->
		<xsl:for-each select="michelin-restaurants/restaurant">

			$(document).on("pageshow", "#" + "<xsl:value-of select="id"/>", function(event) {
				setTimeout( function() {
					var latLng = new google.maps.LatLng(
						<xsl:value-of select="location/longitude"/>,
						<xsl:value-of select="location/latitude"/>
					);

					currentLocation = latLng;

					var options = {
						center: latLng,
						zoom: 15,
						mapTypeId: google.maps.MapTypeId.ROADMAP
					};

					var map = new google.maps.Map($(event.target).find('#map').get(0), options);
					displayedMap = map;
					directionsPanel = $(event.target).find('.map-container').find('#directionsPanel').get(0);


					var marker = new google.maps.Marker({
					    position: latLng,
					    map: map,
					    clickable: true,
					});

					var info = new google.maps.InfoWindow({
				       content: "<xsl:value-of select="name"/>"
				    });

				    info.open(map, marker);

				    google.maps.event.addListener(marker, "click", function (e) { info.open(map, marker); });

				}, 5);
			});
		</xsl:for-each>

		function calcRoute() {
			findUsersLocation(function() {

				var marker = new google.maps.Marker({
				    position: userLocation,
				    map: displayedMap,
				});

				var info = new google.maps.InfoWindow({
					content: "<b>YOU ARE HERE</b>"
				});

				info.open(displayedMap, marker);

				google.maps.event.addListener(marker, "click", function(e) {
					info.open(displayedMap, marker);
				});

				var bounds = new google.maps.LatLngBounds();
				bounds.extend(userLocation);
				bounds.extend(currentLocation);
				displayedMap.fitBounds(bounds);

				var directionsService = new google.maps.DirectionsService();
				var directionsDisplay = new google.maps.DirectionsRenderer();
				directionsDisplay.setMap(displayedMap);
				<!-- directionsDisplay.setPanel(directionsPanel); -->
				var request = {
					origin: userLocation,
					destination: currentLocation,
					travelMode: google.maps.TravelMode.DRIVING
				};
				directionsService.route(request, function(response, status) {
					if (status == google.maps.DirectionsStatus.OK) {
						directionsDisplay.setDirections(response);
					}
				});
			});
		}

		$( document ).on( "pageinit", function() {
		    $( ".photo-popup" ).on({
		        popupbeforeposition: function() {
		            var maxHeight = $( window ).height() - 60 + "px";
		            $( ".photo-popup img" ).css( "max-height", maxHeight );
		        }
		    });
		});

	</script>
</head>

<body> 
	<div data-role="page" id="home">

		<div data-role="header">
			<h1>Restaurants</h1>
		</div>

		<div role="main" class="ui-content">
			<a href="#home-sort" data-role="button" data-inline="true">Sort by Cuisine</a>
			<ul data-role="listview" data-filter="true">
				<xsl:for-each select="michelin-restaurants/restaurant"> 
					<li>
						<a data-transition="slide">
							<xsl:attribute name="href">
								#<xsl:value-of select="id"/>
							</xsl:attribute>
							<img>
								<xsl:attribute name="src">
									<xsl:value-of select="picture-tile"/>
								</xsl:attribute>
							</img>
							<h3><xsl:value-of select="name"/></h3>
							<p><xsl:value-of select="short-description"/></p>
						</a>
					</li>
				</xsl:for-each> 
			</ul>

		</div>

		<div data-role="footer" data-id="f1" data-position="fixed" data-theme="a">
			<div data-role="navbar" data-iconpos="bottom">
				<ul>
					<li><a href="#home" data-icon="grid" class="ui-btn-active ui-state-persist">Restaurants</a></li>
					<li><a href="#map-page" data-transition="fade" data-icon="star">Map</a></li>
				</ul>
			</div>
		</div>

	</div>

	<div data-role="page" id="home-sort">

		<div data-role="header">
			<h1>Restaurants</h1>
		</div>

		<div role="main" class="ui-content">

			<ul data-role="listview" data-filter="true">
				<xsl:for-each select="michelin-restaurants/restaurant"> 
					<xsl:sort select="cuisine"/>
					<li data-role="list-divider" role="heading">
						<xsl:value-of select="cuisine"/>
					</li>
					<li>
						<a data-transition="slide">
							<xsl:attribute name="href">
								#<xsl:value-of select="id"/>
							</xsl:attribute>
							<img>
								<xsl:attribute name="src">
									<xsl:value-of select="picture-tile"/>
								</xsl:attribute>
							</img>
							<h3><xsl:value-of select="name"/></h3>
							<p><xsl:value-of select="short-description"/></p>
						</a>
					</li>
				</xsl:for-each> 
			</ul>

		</div>

		<div data-role="footer" data-id="f1" data-position="fixed" data-theme="a">
			<div data-role="navbar" data-iconpos="bottom">
				<ul>
					<li><a href="#home" data-icon="grid" class="ui-btn-active ui-state-persist">Restaurants</a></li>
					<li><a href="#map-page" data-transition="fade" data-icon="star">Map</a></li>
				</ul>
			</div>
		</div>

	</div>

	<xsl:for-each select="michelin-restaurants/restaurant">
		<div data-role="page">
			<xsl:attribute name="id">
				<xsl:value-of select="id"/>
			</xsl:attribute>

			<div data-role="header" data-add-back-btn="true" data-direction="reverse">
				<h1><xsl:value-of select="name" /></h1>
			</div>

			<div role="main" class="ui-content">
				<div class="wrapper">
					<div class="rest-details">
						<div class="rest-detail-col rest-detail-col-1">
							<div class="rest-description">
								<h4>Description</h4>
								<xsl:copy-of select="long-description/*" />
							</div>
						</div>
						<div class="rest-detail-col rest-detail-col-2">
							<div class="rest-contact">
								<h4>Address</h4>
									<ul>
										<xsl:for-each select="address/*">
											<li>
												<xsl:value-of select="current()" />
											</li>
										</xsl:for-each>
									</ul>
							</div>
							<div class="rest-opening-times">
								<h4>Opening times</h4>
								<ul>
									<xsl:for-each select="opening-times/*">
										<li>
											<h4><xsl:value-of select="name()" /></h4>
											<ul>
												<xsl:if test="breakfast">
													<li>
														<strong>Breakfast: </strong>
														<xsl:value-of select="breakfast" />
													</li>
												</xsl:if>
												<xsl:if test="lunch">
													<li>
														<strong>Lunch: </strong>
														<xsl:value-of select="lunch" />
													</li>
												</xsl:if>
												<xsl:if test="dinner">
													<li>
														<strong>Dinner: </strong>
														<xsl:value-of select="dinner" />
													</li>
												</xsl:if>
												<xsl:if test="open">
													<li><xsl:value-of select="open" /></li>
												</xsl:if>
											</ul>
										</li>
									</xsl:for-each>
								</ul>
							</div>
						</div>
					</div>
					<div class="map-container">
						<a href="#" data-role="button" data-inline="true" onclick="calcRoute()">Directions</a>
						<div id="map"></div>
					</div>
					<div class="photos">
						<xsl:for-each select="pictures/picture">
							<a data-rel="popup" data-position-to="window">
								<xsl:attribute name="href">
									#<xsl:value-of select="current()"/>
								</xsl:attribute>
								<img>
									<xsl:attribute name="src">
										<xsl:value-of select="current()"/>
									</xsl:attribute>
								</img>
							</a>

							<div data-role="popup" class="photo-popup">
								<xsl:attribute name="id">
									<xsl:value-of select="current()"/>
								</xsl:attribute>
								<a href="#" data-rel="back" data-role="button" data-theme="b" data-icon="delete" data-iconpos="notext" class="ui-btn-right">Close</a>
								<img>
									<xsl:attribute name="src">
										<xsl:value-of select="current()"/>
									</xsl:attribute>
								</img>
							</div>
						</xsl:for-each>
						<p>Click to enlarge</p>
					</div>
				</div>
			</div>

		</div>
	</xsl:for-each>

	<div data-role="page" id="map-page">
		<div data-role="header" data-position="fixed">
			<h1>Map</h1>
			<a href="#" onclick="addUsersLocationToMainMap()" data-icon="gear" class="ui-btn-right">Current location</a>
		</div>

		<div role="main" class="ui-content">
			<div id="map"></div>
		</div>

		<div data-role="footer" data-id="f1" data-position="fixed" data-theme="a">
			<div data-role="navbar" data-iconpos="bottom">
				<ul>
					<li><a href="#home" data-transition="fade" data-icon="grid">Restaurants</a></li>
					<li><a href="#map-page" data-icon="star" class="ui-btn-active ui-state-persist">Map</a></li>
				</ul>
			</div>
		</div>

	</div>

</body> 
</html> 

</xsl:template>

</xsl:stylesheet>