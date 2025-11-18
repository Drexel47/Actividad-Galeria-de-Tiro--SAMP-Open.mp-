<h2>Actividad-Galeria de Tiro-(SAMP/Open.mp)</h2>


<p>Codigo base para activar y mostrar una galeria de tiro para mejorar las estadisticas de armas del usuario.</p>


<h3>Descripción</h3>
El sistema generara de forma aleatoria una diana, la levantara, y el usuario deberá dispararle para aumentar en 1 punto su habilidad, el sistema emplea timers de ysi dado a su mejor rendimiento en comparación a los nativos, despues de crear el objeto "acostado", se activara un timer para "levantarlo" y se mantendra asi hasta que se acabe el tiempo, una vez cumplido, el objeto se destruira y generara 
<a href="https://youtu.be/Xt4oHS8iGq4">Video demostración</a>

<h3>Requerimientos</h3>
<ul>
  <li><a href="https://github.com/samp-incognito/samp-streamer-plugin">Streamer Plugin (Dynamic Objects)</a></li>
  <li><a href="https://github.com/pawn-lang/YSI-Includes">YSI (Timers)</a></li>
</ul>

<h3>Consideraciones</h3>
<ul>
  <li> 10 dianas (guardadas en un array (0-9), este valor se considero optimo dadas las dimensiones de la galeria de tiro vanilla, podria aumentar si se emplea alguna galeria custom).
  <li>
    Aumenta la estadistica solo por el primer disparo acertado (Se considero hacerlo similar al juego base, pero los desarrolladores de R* usaron como diana multiples objetos que se dirigen al mismo lugar y a la misma velocidad).
  </li>
</ul>
