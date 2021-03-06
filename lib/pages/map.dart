
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps/pages/MarkerInformation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'as lc;
import 'package:permission_handler/permission_handler.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

const DEFAUL_LOCATION = LatLng(-16.398584,-71.536896);

class _MapsState extends State<Maps> {

  LatLng posicion = DEFAUL_LOCATION;
  MapType  mapType = MapType.normal;
  BitmapDescriptor iconOwn;
  bool isShowInfo=false;
  GoogleMapController controller;

  LatLng latLgnOnLongPres;
  lc.Location location;

  bool  _myLocationEnabled =false;//activado mi localizacion
  bool  _myLocationButtonEnabled= false;// poner visible el boton

  LatLng _curretLocation = DEFAUL_LOCATION;

  //para que las imagenes carge antes de todo
  @override
  void initState() { 
    super.initState();
    getIcons();
    requestPerms();
  }
  // LOCALIZACION DE USUARIO ACTUAL
  getLocationUser() async {
    var _curretLocation = await location.getLocation();
    updateLocationUser(_curretLocation);
  }

  updateLocationUser( currentLocation){ //actualizar en real time location users
    if (currentLocation !=null) {
      print("Ubicacion actual del Usuario Latitud : ${currentLocation.latitude} Longuitud: ${currentLocation.longitude}");
      setState(() {
        this._curretLocation=LatLng(currentLocation.latitude,currentLocation.longitude);
        this.controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target:this._curretLocation ,
            zoom: 17,
          )
        )); //actualizar la camara
      });
      
    }
  }
  locationChangedUser(){ //obtener contantemente la ubicacion del usuario
  
  location.onLocationChanged.listen((lc.LocationData cloc) { 
    if (cloc != null) {
      updateLocationUser(cloc) ;
    }
  });

  }
 // ACTIVAR LOS PERMISOS DE USO GPS
  requestPerms()async{
    Map<Permission,PermissionStatus> statuse = await [Permission.locationAlways].request(); //dentro de [] puedes agregar mas permisos,

     var status = statuse[Permission.locationAlways];

     if (status==PermissionStatus.denied) {

       requestPerms();
     }
     else
     {
        enableGPS();
     }
  }
  enableGPS()async{
    location=lc.Location();
    bool servicesStatusResult = await location.requestService();

    if (!servicesStatusResult) {

      enableGPS();
    }
    else{
       print("GPS Activado");
       updateStatus();
       getLocationUser();
       locationChangedUser();
    }
  }

  updateStatus(){
    setState(() {
        _myLocationEnabled =true;//activado mi localizacion
        _myLocationButtonEnabled= true;// poner visible el boton
    });
  }

  getIcons()async{

     var icons = await BitmapDescriptor.fromAssetImage(
       ImageConfiguration(devicePixelRatio: 2.0),
       'assets/img/driving-pin.png');
       
       //actualizar el icono
       setState(() {
         iconOwn =icons;
       });
   }
  //-16.398584, -71.536896
  _onMapCreated(GoogleMapController controller){

    this.controller= controller;

  }
  ontTapMap(LatLng latLng){
    print("OnTapMap $latLng");
  }
  onLongPressMap(LatLng latLng){
    latLgnOnLongPres=latLng;

    showPopUpMenu() ;

  }
  showPopUpMenu() async{
    String selected = await showMenu(
      context: context, 
      position: RelativeRect.fromLTRB(200, 200, 250, 250), 
      items: [
        PopupMenuItem<String>(
          child: Text("Que hay Aqui"),
          value: "QueHay",
        )
        ,
        PopupMenuItem<String>(
          child: Text("Ir a"),
          value: "Ir",
        )
        ,
        
      ]
       ,
      elevation: 8.0
    );

    if (selected !=null) {
      getValue(selected);
      
    }

  }

  getValue(value){

    if (value =="QueHay") {
      print("Ubicacion $latLgnOnLongPres");
    }
  }
  @override
  Widget build(BuildContext context) {

    //BitmapDescriptor icono = BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),"assets/img/driving-pin.png");
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: Stack(
        children: <Widget>[

          GoogleMap(
            //desahabilitar propiedades como inclinacion ,Scrool , zoom
            /* rotateGesturesEnabled: ,
            scrollGesturesEnabled: ,
            zoomGesturesEnabled: ,
            tiltGesturesEnabled: , */

            compassEnabled: true,//Brujula
            mapToolbarEnabled: true,//barra de herramientas
            trafficEnabled: true, //trafico
            buildingsEnabled: true,//ver edificios en 3D
            initialCameraPosition: CameraPosition(
              target:posicion,
              zoom: 15,    
              bearing: 90,//orientacion   
              tilt:45 //inclinacion
            ),

            myLocationEnabled: _myLocationEnabled,//activado mi localizacion
            myLocationButtonEnabled: _myLocationButtonEnabled,// poner visible el boton

            onTap:ontTapMap , //Detecta cuando nostros presiones la mapa
            onLongPress: onLongPressMap,//Detecta cuando nosotros tardamos en presiones la mapa
            
            onCameraMoveStarted: ()=>{
              print("Inicio ")
            },// Detecta el movimiento de camara
            onCameraIdle: ()=>{
              print("Fin")
            },//Detecta cuando la camara deja de moverse
            onCameraMove: (CameraPosition cameraPosition)=>{
             print(" Moviendo ${cameraPosition.target }")
            },//Detecta ci¿uando la camera se esta moviendo devuelve un valor
            onMapCreated: _onMapCreated,


             mapType:mapType,
            /*  cameraTargetBounds: CameraTargetBounds(LatLngBounds(
               southwest: null, 
               northeast: null) 
             ), */ //para delimitar la mapa
            // minMaxZoomPreference: MinMaxZoomPreference(1,10),// delimitar el zoom
             markers: {
               Marker( 
                 markerId: MarkerId(posicion.toString()),
                 position: posicion,
                 //alpha: 0.7,//opacidad dee marcador
                // anchor: const Offset(0.2, 0.2), 
                // draggable: true, //puede mover el marcador,
                // onDragEnd: _onDragEnd, //devuelve una nueva posicion
                // zIndex: 1,
                 //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
               // icon: iconOwn,
                 icon:BitmapDescriptor.fromAsset("assets/img/driving-pin.png"),
                 onTap: (){

                   print("Hola Mundo");

                   //isShowInfo =! isShowInfo;
                    setState(() {
                      
                      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                        target: LatLng(-16.398584,-71.536896),
                        zoom: 10

                      )));

                      this.isShowInfo =! this.isShowInfo;

                      }); 
                   
                 }
                 /* infoWindow: InfoWindow(
                   title: "Informacion del Marcador",
                  // snippet: "Latitud : ${posicion.latitude}  & Longuitud : ${posicion.longitude}"
                  onTap: (){
                   
                  }
                 ) */
              ),

              Marker( 
                
                 markerId: MarkerId(posicion.toString()),
                 position: LatLng(-16.388409958978677, -71.54798112809658),
                 alpha: 0.7,//opacidad dee marcador
                 anchor: const Offset(0.2, 0.2), 
                 draggable: true, //puede mover el marcador,
                 onDragEnd: _onDragEnd, //devuelve una nueva posicion
                 zIndex: 2,
                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)
                // icon: iconOwn
              ),
                 
             },
          ),
           
         _speedDial(),

        Visibility(visible:isShowInfo , child: MarkerInformaction( image: "assets/img/cody.jpg", title: "Mi Ubicacion", latLng: this.posicion,))


        ],
      ),
      
    );
  }

  Widget _speedDial(){

    return Container(
     
      padding: EdgeInsets.only(bottom: 100.0,right: 5.0),
      child: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            elevation: 8.0,
            children: [
              SpeedDialChild(
                label: "NORMAL",
                child: Icon(Icons.room),
                onTap: ()=>setState(()=>mapType= MapType.normal)
              ),

              SpeedDialChild(
                label: "SATELLITE",
                child: Icon(Icons.satellite),
                onTap: ()=>setState(()=>mapType= MapType.satellite)
              ),

              SpeedDialChild(
                label: "HYBRID",
                child: Icon(Icons.compare),
                onTap: ()=>setState(()=>mapType= MapType.hybrid)
              ),

              SpeedDialChild(
                label: "TERRAIN",
                child: Icon(Icons.terrain),
                onTap: ()=>setState(()=>mapType= MapType.terrain)
              )

            ],
            

          ),
           
        
    );
  }

  _onDragEnd(LatLng posicion){

    print("New Posicion : $posicion");

  }
}