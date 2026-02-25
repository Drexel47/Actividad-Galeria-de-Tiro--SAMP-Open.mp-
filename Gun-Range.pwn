
new bool:UsuarioDelay[MAX_PLAYERS]; //Booleano para aplicar un delay al jugador para que no acapare la galeria de tiro

enum UserStatsInSR
{
    bool:ArmaPrestada,//Booleano para revisar si el usuario tiene un arma activa o hay que "prestar" una
    tiroAcertado,
    tiroFallado,
    tirosTotales
}
new UserStatsSH[MAX_PLAYERS][UserStatsInSR];


#define MAX_GALERIA_TIRO 2
#define MAX_TARGETS 8
#define GALERIA_MIN 1 //Tiempo en min para usar la galeria de tiro
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
        {275.6333, -137.6755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},//Larga Distancia
        {275.6333, -132.6755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},
        {280.6333, -140.1755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},//Media Distancia
        {280.6333, -135.1755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},
        {280.6333, -130.1755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},
        {285.6333, -137.6755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},//Corta Distancia
        {285.6333, -132.6755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010},
        {290.6333, -135.1755, 1002.9752, -90.0, 0.0, 90.0, 7, 3010} //Muy Corta Distancia
    },
    {
        //rot eje x
        {805.57788, 1650.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0}, // 1655, 4.26810
        {801.57788, 1650.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0},
        {797.61823, 1650.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0},
        {803.57788, 1643.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0},
        {799.57788, 1643.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0},
        {805.57788, 1637.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0},
        {801.57788, 1637.22864, 4.06810,  -90.0, 0.0, 0.0, 0, 0},
        {797.61823, 1637.24792, 4.06810,  -90.0, 0.0, 0.0, 0, 0}

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
    gIndex, //Indice de GunTargets
    modeloDiana, //Modelo
    gFaccion
}

new GaleriaTiro[MAX_GALERIA_TIRO][GaleriaTiroData];
new Iterator:GT_iter<MAX_GALERIA_TIRO>;


stock CargarGaleriasTiro()
{
    RegistrarGaleriaTiro(302.2701, -135.0395, 1003.0503, 7, 3010, LSPD);
    RegistrarGaleriaTiro(800.652221, 1675.355468, 4.5812,0, 0);


    return 1;
}

stock RegistrarGaleriaTiro(Float:gx1, Float:gy1, Float:gz1, gint1, gvw1, faccion = CIVIL)
{
    new g = Iter_Free(GT_iter);
    if (g == -1) return printf("Error al registrar la galeria de tiro");


    GaleriaTiro[g][gx] = gx1;
    GaleriaTiro[g][gy] = gy1;
    GaleriaTiro[g][gz] = gz1;
    GaleriaTiro[g][gint] = gint1;
    GaleriaTiro[g][gvw] = gvw1;

    GaleriaTiro[g][gTID] = CreateDynamicPickup(2061, 1, GaleriaTiro[g][gx], GaleriaTiro[g][gy], GaleriaTiro[g][gz] + 1.0, GaleriaTiro[g][gvw], GaleriaTiro[g][gint], -1, 20.0);
    GaleriaTiro[g][gEstado] = false; //Inactivo
    GaleriaTiro[g][gPlayer] = INVALID_PLAYER_ID; //Se asigna el valor de usuario "invalido" al inicio
    GaleriaTiro[g][gFaccion] = faccion;

    Iter_Add(GT_iter, g);

    return 1;
}



stock NumeroAleatorioSinRepetir(prev, max)
{
    if (max <= 1) return 0;
    new r = random(max);
    while (r == prev) r = random(max);


    //printf("Numero viejo: %i, Numero Nuevo: %i", prev, r);
    return r;
}

new TargetModels[] = {1583, 1584, 1585}; //Modelos visibles disponibles para las dianas

stock CrearDiana(playerid, gid)
{
    if (!Iter_Contains(GT_iter, gid)) return printf("[Error] Crear Diana");

    new limite = sizeof(GunTargets[]);

    new index = GaleriaTiro[gid][gIndex];

    if (index == -1) index = random(limite);
    else index = NumeroAleatorioSinRepetir(index, limite);

    if (gid < 0 || gid > limite) return printf("[ERROR] Al crear diana.");

    GaleriaTiro[gid][gIndex] = index;

    new posDiana = random(sizeof(TargetModels));
    if (Usuarios[playerid][AdminOnDuty]) SendClientMessage(playerid, -1, "Debug: gid:%i indice:%i limite %i", gid, posDiana, limite);

    GaleriaTiro[gid][modeloDiana] = TargetModels[posDiana];
    GaleriaTiro[gid][gObj] = CreateDynamicObject(
                                 TargetModels[posDiana],
                                 GunTargets[gid][index][gTx],
                                 GunTargets[gid][index][gTy] - 0.001,
                                 GunTargets[gid][index][gTz],
                                 GunTargets[gid][index][gTrx],
                                 GunTargets[gid][index][gTry],
                                 GunTargets[gid][index][gTrz],
                                 GunTargets[gid][index][gTvw],
                                 GunTargets[gid][index][gTint],
                                 playerid,
                                 100.0, 100.0
                             );

    Streamer_Update(playerid);

    if (GunTargets[gid][index][gTrx] == -90.0 || GunTargets[gid][index][gTrx] == 90.0) defer ObjetivoLevantado(gid, 0);

    if (Usuarios[playerid][AdminOnDuty]) SendClientMessage(playerid, -1, "x:%f y:%f z:%f w:%i int:%i", GunTargets[gid][index][gTx],  GunTargets[gid][index][gTy] - 0.001,  GunTargets[gid][index][gTz],  GunTargets[gid][index][gTvw], GunTargets[gid][index][gTint]);
    if (Usuarios[playerid][AdminOnDuty]) if (!IsValidDynamicObject(GaleriaTiro[gid][gObj])) SendClientMessage(playerid, -1, "Error!"); //Debug
    
    //printf("Angulo: %f", GunTargets[g][index][gTrx]);
    if (GunTargets[gid][index][gTrx] == -90.0 || GunTargets[gid][index][gTrx] == 90.0) defer ObjetivoLevantado(gid, 0);

    if(GaleriaTiro[gid][modeloDiana] == 1585) defer DestruirDiana(gid);
    return 1;
}

stock GaleriaTiroCercana(playerid)
{
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    new gid = -1;
    foreach (new g : GT_iter)
    {
        if (vw == GaleriaTiro[g][gvw] && interior == GaleriaTiro[g][gint])
        {
            if (IsPlayerInRangeOfPoint(playerid, 2.0, GaleriaTiro[g][gx], GaleriaTiro[g][gy], GaleriaTiro[g][gz]))
            {
                gid = g;
                break;
            }
        }
    }
    return gid;
}


COMMAND:galeria(playerid, params[]) //Comando para activar la actividad de "Galeria de Tiro"
{
    if (!isnull(params)) return 0;

    VerificarDelay(playerid, dGaleriaTiro);
    


    new armaid = GetPlayerWeapon(playerid);
    if (armaid == -1) return 0;
    if (armaid > 0 && (armaid < 22 || armaid > 32)) return SendClientMessage(playerid, -1, "No puedes usar la Galeria de Tiro con esta arma!");

    new pos = GaleriaTiroCercana(playerid);
    if (pos == -1) return SendClientMessage(playerid, -1, "No estas cerca de alguna Galeria de Tiro!");

    if (Usuarios[playerid][AdminOnDuty]) SendClientMessage(playerid, -1, "[DEBUG] GALERIA DE TIRO: gid: %i", pos);

    if(armaid == 0)
    {
        SendClientMessage(playerid, -1, "Elige un arma para comenzar la galeria de tiro:");
        SetPVarInt(playerid, "gid", pos);
        new str[64];
        format(str, sizeof(str), "%sPistola 9mm\n9mm SD\nDesert Eagle\nEscopeta\nAK-47\nM4\nMP5", str);
        ShowPlayerDialog(playerid, GALERIA_TIRO, DIALOG_STYLE_LIST, "Galeria de Tiro", str, "Aceptar", "Cancelar");

        return 1;
    }
    UserStatsSH[playerid][ArmaPrestada] = false; //Arma Propia
    OnGaleriadeTiro(playerid, pos);
    return 1;
}

stock OnGaleriadeTiro(playerid, gid)
{
    if (GaleriaTiro[gid][gEstado]) return SendClientMessage(playerid, -1, "La galeria de tiro esta ocupada!");
    if (GaleriaTiro[gid][gPlayer])
        if (GaleriaTiro[gid][gPlayer] == INVALID_PLAYER_ID) GaleriaTiro[gid][gPlayer] = playerid; //Asigno el jugador en la galeria de tiro
        else if (GaleriaTiro[gid][gPlayer] == playerid) return SendClientMessage(playerid, -1, "Ya tienes asignada esta galeria de tiro!");
        else if (GaleriaTiro[gid][gPlayer] != playerid) return SendClientMessage(playerid, -1, "Alguien mas ya esta usando esta galeria de tiro!");

    GaleriaTiro[gid][gEstado] = true; //Galeria Ocupada
    GaleriaTiro[gid][gIndex] = -1;  //Valor arbitrario
    GaleriaTiro[gid][modeloDiana] = -1; //Valor Arbitrario
    ActividadesUsuario[playerid][EnGaleriadeTiro] = false; //Valor inicial del estado
    SendClientMessage(playerid, -1, "Preparate! La galeria de tiro comenzara en breve.");

    defer CuentaAtrasGT(playerid, 3, gid);

    return 1;
}

timer CuentaAtrasGT[1000](playerid, tiempo, gid)
{
    if (!Iter_Contains(GT_iter, gid)) return;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if (Usuarios[playerid][AdminOnDuty]) SendClientMessage(playerid, -1, "gid: %i", gid);

    if (tiempo > 0)
    {
        new str[8];
        format(str, sizeof(str), "%i", tiempo);
        GameTextForPlayer(playerid, str, 1000, 3);
        PlayerPlaySound(playerid, 1058, x, y, z);
        tiempo--;
        defer CuentaAtrasGT(playerid, tiempo, gid);
    }
    else
    {
        new timestamp = gettime();
        new tiempo_limite = timestamp + (GALERIA_MIN * 60);
        ActividadesUsuario[playerid][EnGaleriadeTiro] = true; //Usuario en Galeria de tiro activo
        UserStatsSH[playerid][tiroAcertado] = 0;
        UserStatsSH[playerid][tiroFallado] = 0;
        UserStatsSH[playerid][tirosTotales] = 0;
        PlayerPlaySound(playerid, 3200, x, y, z);
        SendClientMessage(playerid, -1, "Ha comenzado la galeria de tiro!");

        CrearDiana(playerid, gid); //Creo Diana
        defer GaleriaTiroActiva(playerid, tiempo_limite, gid);
    }
}


timer GaleriaTiroActiva[1000](playerid, limite_tiempo, gid)
{
    new tiempo_actual = gettime();

    new restante = limite_tiempo - tiempo_actual;

    new str[36];
    //SendClientMessage(playerid, -1, "%i", restante);
    if (restante >= 45) format(str, sizeof(str), "~g~%i", restante); //Verde
    if (restante >= 30) format(str, sizeof(str), "~b~~h~~h~%i", restante); //Azul claro
    else if (restante >= 15) format(str, sizeof(str), "~r~~h~~h~~h~~h~%i", restante); //Rojo claro
    else format(str, sizeof(str), "~r~~h~%i", restante); //Rojo


    GameTextForPlayer(playerid, str, 1000, 9);
    new Float:x, Float:y, Float:z;
    if (restante <= 10)PlayerPlaySound(playerid, 1058, x, y, z);
    //if (IsValidDynamicObject(GaleriaTiro[gid][gObj])) DestroyDynamicObject(GaleriaTiro[gid][gObj]); //Para hacer la mejora de los stats de armas, se debe usar la funcion nativa de Streamer "OnPlayerShootDynamicObject"




    if (restante <= 0)
    {
        if (IsValidDynamicObject(GaleriaTiro[gid][gObj])) DestroyDynamicObject(GaleriaTiro[gid][gObj]);
        
        PlayerPlaySound(playerid, 3200, x, y, z);

        new Float:precision = 0.0;
        
        if (UserStatsSH[playerid][tirosTotales] > 0) precision = (UserStatsSH[playerid][tiroAcertado] * 100.0) / UserStatsSH[playerid][tirosTotales];

        if(Usuarios[playerid][AdminOnDuty]) SendClientMessage(playerid, -1, "Total: %i disparos", UserStatsSH[playerid][tirosTotales]);

        SendClientMessage(playerid, -1, "Se ha terminado el tiempo! Tiros acertados: %i, Precision: %.2f%%", UserStatsSH[playerid][tiroAcertado], precision);
        GaleriaTiro[gid][gEstado] = false; //Desocupado
        UsuarioDelay[playerid] = true;
        GaleriaTiro[gid][gPlayer] = INVALID_PLAYER_ID; //Limpio el jugador asignado a la galeria de tiro
        GaleriaTiro[gid][gIndex] = -1;
        ActividadesUsuario[playerid][EnGaleriadeTiro] = false;
        
        if(UserStatsSH[playerid][ArmaPrestada])
        {
            new armaid = GetPlayerWeapon(playerid);
            RemovePlayerWeapon(playerid, armaid);
            ArmaActivaUsuario[playerid] = -1; //Eliminar Arma activa
            UserStatsSH[playerid][ArmaPrestada] = false; //Si tenia arma "prestada" eliminarla por completo
            

        }
        UserStatsSH[playerid][tiroAcertado] = 0;
        UserStatsSH[playerid][tiroFallado] = 0;
        UserStatsSH[playerid][tirosTotales] = 0;

        AgregarDelayActividad(playerid, dGaleriaTiro);

        //defer GR_Delay(playerid); //Añado un delay para que el jugador no siga avanzando
        return;
    }

    //CrearDiana(playerid, gid);
    defer GaleriaTiroActiva(playerid, limite_tiempo, gid);

}

timer ObjetivoLevantado[500](gid, eje)
{
    new index = GaleriaTiro[gid][gIndex];

    if (index == -1) return; // seguridad

    if (eje == 0)
    {
        SetDynamicObjectRot(
            GaleriaTiro[gid][gObj],
            0.0,
            GunTargets[gid][index][gTry],
            GunTargets[gid][index][gTrz]
        );
    }
    else if (eje == 1)
    {
        SetDynamicObjectRot(
            GaleriaTiro[gid][gObj],
            GunTargets[gid][index][gTrx],
            0.0,
            GunTargets[gid][index][gTrz]
        );
    }
}

timer GR_Delay[1 * 60000](playerid)
{
    UsuarioDelay[playerid] = false;

}

timer DestruirDiana[1000](gid) 
{
    if (!Iter_Contains(GT_iter, gid)) return;

    if(GaleriaTiro[gid][modeloDiana] == 1585)
    {
        if (IsValidDynamicObject(GaleriaTiro[gid][gObj]))
        {
                
            DestroyDynamicObject(GaleriaTiro[gid][gObj]);
            GaleriaTiro[gid][gObj] = INVALID_STREAMER_ID;

            // Crear nueva diana después de que el civil se vaya
            CrearDiana(GaleriaTiro[gid][gPlayer], gid);
            
        }
    }
    

}

stock string:GaleriasTiroDisponibles(playerid)
{
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new msg[2048];
    new count = 0;
    foreach (new g : GT_iter)
    {
        if(GaleriaTiro[g][gint] = int && GaleriaTiro[g][gvw] == vw)
        {
            new aux[24];
            new Float:dist = GetDistanceBetweenPoints(x, y, z, GaleriaTiro[g][gx], GaleriaTiro[g][gy], GaleriaTiro[g][gz]);
            format(aux, sizeof(aux), "Galeria de Tiro %d (%.2fm)\n", count, dist);
            strcat(msg, aux);
            count++;
        }   


    }

    return msg;
}