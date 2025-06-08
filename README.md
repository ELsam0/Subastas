# 🧾 Contrato Inteligente de Subasta

Este contrato inteligente permite realizar una subasta transparente en la blockchain Ethereum (Red Sepolia), donde los participantes pueden ofertar en tiempo real y con reglas claras y automáticas.

---

## ⚙️ Funcionalidades principales

- Inicialización con duración personalizada.
- Ofertas válidas si son al menos 5% mayores a la anterior.
- Extensión de subasta automática si se ofrece en los últimos 10 minutos.
- Visualización de ganador y lista de oferentes.
- Devolución de fondos a oferentes no ganadores, menos 2% de comisión.
- Reembolso parcial del excedente sobre ofertas anteriores.

---

## 🧠 Variables

| Variable            | Tipo         | Descripción                                                  |
|---------------------|--------------|--------------------------------------------------------------|
| `dueño`             | `address`    | Dirección del creador del contrato.                          |
| `mejorPostor`       | `address`    | Dirección del ofertante con la mayor oferta.                 |
| `mejorOferta`       | `uint`       | Valor de la mayor oferta hasta el momento.                   |
| `finSubasta`        | `uint`       | Tiempo UNIX cuando finaliza la subasta.                      |
| `finalizada`        | `bool`       | Indica si la subasta fue finalizada.                         |
| `constanteComision` | `uint`       | Comisión fija del 2% para devolución de depósitos.           |
| `oferentes`         | `address[]`  | Lista de todos los oferentes únicos.                         |
| `depositos`         | `mapping`    | Cantidad total depositada por cada oferente.                 |
| `historialOfertas`  | `mapping`    | Historial de ofertas individuales por cada oferente.         |

---

## 🧩 Funciones

| Función                 | Visibilidad    | Descripción                                                                 |
|-------------------------|----------------|-----------------------------------------------------------------------------|
| `constructor(uint)`     | `public`       | Inicializa la subasta con duración en minutos.                             |
| `ofertar()`             | `external`     | Permite hacer una oferta si es válida y extiende el tiempo si aplica.      |
| `mostrarGanador()`      | `external view`| Devuelve el ganador y su oferta. Solo tras finalizar la subasta.           |
| `mostrarOfertas()`      | `external view`| Devuelve la lista de oferentes y montos depositados.                       |
| `finalizarSubasta()`    | `external`     | Solo el dueño puede finalizar formalmente la subasta.                      |
| `devolverDepositos()`   | `external`     | Devuelve el depósito a oferentes no ganadores, menos 2%.                   |
| `reembolsoParcial()`    | `external`     | Permite retirar el excedente de ofertas anteriores durante la subasta.     |

---

## 🧷 Modificadores

| Modificador          | Descripción                                      |
|----------------------|--------------------------------------------------|
| `soloAntesDelFinal`  | Asegura que se ejecuta antes del fin de subasta. |
| `soloDespuesDelFinal`| Asegura que se ejecuta luego del fin.            |
| `soloDueño`          | Solo el creador del contrato puede ejecutar.     |

---

## 📢 Eventos

| Evento               | Descripción                                                              |
|----------------------|--------------------------------------------------------------------------|
| `NuevaOferta`        | Se emite cada vez que se hace una oferta válida.                         |
| `SubastaFinalizada`  | Se emite una vez que el dueño finaliza oficialmente la subasta.          |

---

