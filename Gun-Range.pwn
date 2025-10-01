enum gTarget
{
    gTID,
    Float:gX, 
    Float:gY, 
    Float:gZ,
}
new bool:UsuarioDelay[MAX_PLAYERS]; //Booleano para aplicar un delay al jugador para que no acapare la galeria de tiro
new bool:UsuarioEnGT[MAX_PLAYERS]; //Booleano para asignar si el usuario esta en una galeria de tiro.

#define MAX_GALERIA_TIRO 3
#define MAX_TARGETS 10

enum gT_DATA
{
    Float:gTx, 
    Float:gTy, 
    Float:gTz, 
    Float:gTrx, 
    Float:gTry, 
    Float:gTrz,
    gTint,
    gTvw


}
new GunTargets[][][gT_DATA] =  //Posiciones predeterminadas de las dianas
{
    
    {
        {295.63327, -137.67546, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {285.63330, -137.67551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {275.63330, -137.67551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {295.63330, -132.67551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {285.63330, -132.67551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {275.63330, -132.67551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {290.63330, -135.17551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010},
        {280.63330, -135.17551, 1002.97522,   -90.0, 0.0, 90.0, 7, 3010}
    }

};
enum GaleriaTiroData
{
    gTID, //id del pickup
    gPlayer, //Id del usuario a quien se le asigna
    gObj, //Id del objeto de la diana
    //Posicion (x, y, z) e interior y virtualworld
    Float:gx,
    Float:gy,
    Float:gz,
    gint, 
    gvw,
    bool:gEstado, //Ocupado - Desocupado
    gIndex //Indice de GunTargets
}

new GaleriaTiro[MAX_GALERIA_TIRO][GaleriaTiroData];
new Iterator: GT_iter<MAX_GALERIA_TIRO>;


stock CargarGaleriasTiro()
{
    RegistrarGaleriaTiro(302.2701, -135.0395, 1003.0503, 7, 3010);


    return 1;
}

stock RegistrarGaleriaTiro(Float:gx1, Float:gy1, Float:gz1, gint1, gvw1)
{
    new g = Iter_Free(GT_iter);
    if(g == -1) return printf("Error al registrar la galeria de tiro");

    
    GaleriaTiro[g][gx] = gx1;
    GaleriaTiro[g][gy] = gy1;
    GaleriaTiro[g][gz] = gz1;
    GaleriaTiro[g][gint] = gint1;
    GaleriaTiro[g][gvw] = gvw1;

    GaleriaTiro[g][gTID] = CreateDynamicPickup(2061, 1, GaleriaTiro[g][gx], GaleriaTiro[g][gy], GaleriaTiro[g][gz] + 1.0, GaleriaTiro[g][gvw], GaleriaTiro[g][gint], -1, 20.0);
    GaleriaTiro[g][gEstado] = false; //Inactivo
    GaleriaTiro[g][gPlayer] = INVALID_PLAYER_ID; //Se asigna el valor de usuario "invalido" al inicio
    Iter_Add(GT_iter, g);

    return 1;
}


timer CuentaAtrasGT[1000](playerid, tiempo, g)
{
    if(!Iter_Contains(GT_iter, g)) return;

    if(tiempo > 0){
        SendClientMessage(playerid, -1, "%i", tiempo);
        tiempo--;
        defer CuentaAtrasGT(playerid, tiempo, g);
    }else
    {
        UsuarioEnGT[playerid]=true; //Usuario en Galeria de tiro activo
        SendClientMessage(playerid, -1, "Ha comenzado la galeria de tiro!");
        defer GaleriaTiroActiva(playerid, 60, g,  GaleriaTiro[g][gIndex]);
    }
}

timer GaleriaTiroActiva[1000](playerid, tiempo, g, index)
{
    printf("Tiempo: %i, Index: %i", tiempo, index); //Debug

    if(IsValidDynamicObject(GaleriaTiro[g][gObj])) DestroyDynamicObject(GaleriaTiro[g][gObj]); //Para hacer la mejora de los stats de armas, se debe usar la funcion nativa de Streamer "OnPlayerShootDynamicObject"
    if(tiempo > 0)
    {
        CrearDiana(playerid, g, index);
        tiempo--;
        defer GaleriaTiroActiva(playerid, tiempo, g, GaleriaTiro[g][gIndex]);
    }
    else
    {
        SendClientMessage(playerid, -1, "Se ha terminado el tiempo!");
        GaleriaTiro[g][gEstado] = false; //Desocupado
        UsuarioDelay[playerid]= true;
        GaleriaTiro[g][gPlayer] = INVALID_PLAYER_ID; //Limpio el jugador asignado a la galeria de tiro
        GaleriaTiro[g][gIndex] = -1;
        UsuarioEnGT[playerid]=false;
        defer GR_Delay(playerid); //Añado un delay para que el jugador no siga avanzando
    }

}

timer GR_Delay[1*60000](playerid)
{
    UsuarioDelay[playerid] = false;


}


stock NumeroAleatorioSinRepetir(prev, max)
{
    if (max <= 1) return 0;
    new r = random(max);
    while (r == prev) r = random(max);


    printf("Numero viejo: %i, Numero Nuevo: %i", prev, r);
    return r;
}
new TargetModels[] = {1583, 1584}; //Modelos visibles disponibles para las dianas

stock CrearDiana(playerid, g, index)
{
    new limite = random(sizeof(GunTargets[]));
    //printf("limite: %i", limite);

    if(index == -1) index = random(limite);
    else index = NumeroAleatorioSinRepetir(index, limite);

    GaleriaTiro[g][gIndex] = index;

    new posDiana = random(sizeof(TargetModels));
    //printf("PosX:%f", GunTargets[g][index][gTx]);
    if(TargetModels[posDiana] == 1584) GaleriaTiro[g][gObj] = CreateDynamicObject(TargetModels[posDiana], GunTargets[g][index][gTx],  GunTargets[g][index][gTy] - 0.001,  GunTargets[g][index][gTz],  GunTargets[g][index][gTrx],  GunTargets[g][index][gTry],  GunTargets[g][index][gTrz],  GunTargets[g][index][gTvw], GunTargets[g][index][gTint], playerid, 20.0);
    else GaleriaTiro[g][gObj] = CreateDynamicObject(TargetModels[posDiana], GunTargets[g][index][gTx],  GunTargets[g][index][gTy],  GunTargets[g][index][gTz] + 0.016,  GunTargets[g][index][gTrx],  GunTargets[g][index][gTry],  GunTargets[g][index][gTrz],  GunTargets[g][index][gTvw], GunTargets[g][index][gTint], playerid, 20.0);
    //1584 es 0.017 mas alto que 1583
    Streamer_Update(playerid);

    //printf("Angulo: %f", GunTargets[g][index][gTrx]);
    if(GunTargets[g][index][gTrx] == -90.0 || GunTargets[g][index][gTrx] == 270.0) defer ObjetivoLevantado(g, 0, index);
    
}

timer ObjetivoLevantado[500](g, eje, index) //Timer para "levantar" la diana, se considera un valor "eje" para hacerlo, x = 0, y = 1
{

    if(eje == 0) SetDynamicObjectRot(GaleriaTiro[g][gObj], 0.0,  GunTargets[g][index][gTry],  GunTargets[g][index][gTrz]);
    else if(eje == 1) SetDynamicObjectRot(GaleriaTiro[g][gObj], GunTargets[g][index][gTrx],  0.0,  GunTargets[g][index][gTrz]);


}

COMMAND:galeria(playerid, params[]) //Comando para activar la actividad de "Galeria de Tiro"
{
    if(!isnull(params)) return 0;
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    new pos = -1;
    foreach(new g : GT_iter)
    {
        if(vw == GaleriaTiro[g][gvw] && interior == GaleriaTiro[g][gint])
        {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, GaleriaTiro[g][gx], GaleriaTiro[g][gy], GaleriaTiro[g][gz]))
            {
                pos = g;
                break;
            }
        }
    }

    if(pos == -1) return SendClientMessage(playerid, -1, "No estas cerca de alguna galeria de tiro!");
    if(GaleriaTiro[pos][gEstado]) return SendClientMessage(playerid, -1, "La galeria de tiro esta ocupada!");
    if(GaleriaTiro[pos][gPlayer])
    if(GaleriaTiro[pos][gPlayer] == INVALID_PLAYER_ID) GaleriaTiro[pos][gPlayer] = playerid; //Asigno el jugador en la galeria de tiro
    else if (GaleriaTiro[pos][gPlayer] == playerid) return SendClientMessage(playerid, -1, "Ya tienes asignada esta galeria de tiro!");
        else if(GaleriaTiro[pos][gPlayer] != playerid) return SendClientMessage(playerid, -1, "Alguien mas ya esta usando esta galeria de tiro!");
    
    GaleriaTiro[pos][gEstado] = true; //Galeria Ocupada
    GaleriaTiro[pos][gIndex] = -1;  //Valor arbitrario
    UsuarioEnGT[playerid]=false; //Valor inicial del estado
    SendClientMessage(playerid, -1, "Preparate! La galeria de tiro comenzara en breve.");
    defer CuentaAtrasGT(playerid, 3, pos);

    return 1;
}