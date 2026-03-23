
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect

app = FastAPI()

MAX_PLAYERS = 4
MIN_PLAYERS = 3


class Player:
    def __init__(self, player_id: int, name: str, ws: WebSocket):
        self.player_id = player_id
        self.name = name
        self.ws = ws


class Room:
    def __init__(self):
        self.players: dict[int, Player] = {}
        self.started: bool = False
        self.next_id: int = 1
    
    def add(self, name: str, ws: WebSocket) -> Player:
        p = Player(self.next_id, name, ws)
        self.players[self.next_id] = p
        self.next_id += 1
        return p
    
    def remove(self, player_id: int) -> None:
        self.players.pop(player_id, None)
    
    def is_full(self) -> bool:
        return len(self.players) >= MAX_PLAYERS
    
    def host_id(self) -> int | None:
        if not self.players:
            return None
        return min(self.players.keys())
    
    def players_payload(self) -> list[dict]:
        return [{"id": p.player_id, "name": p.name} for p in self.players.values()]


room = Room()


async def send(ws: WebSocket, payload: dict) -> None:
    await ws.send_text(json.dumps(payload))


async def broadcast(payload: dict, exclude: int | None = None) -> None:
    for p in list(room.players.values()):
        if p.player_id == exclude:
            continue
        try:
            await send(p.ws, payload)
        except Exception:
            pass


async def broadcast_all(payload: dict) -> None:
    await broadcast(payload, exclude=None)


async def handle_join(ws: WebSocket, msg: dict) -> "Player | None":
    name: str = msg.get("name", "").strip()
    
    if not name:
        await send(ws, {"action": "error", "reason": "Nome inválido."})
        return None
    if room.is_full():
        await send(ws, {"action": "error", "reason": "Sala cheia."})
        return None
    if room.started:
        await send(ws, {"action": "error", "reason": "Partida já iniciada."})
        return None
    
    player = room.add(name, ws)
    
    await send(ws, {
        "action": "joined",
        "player_id": player.player_id,
        "name": player.name,
        "players": room.players_payload(),
    })
    
    await broadcast_all({
        "action": "lobby_update",
        "players": room.players_payload(),
        "host_id": room.host_id(),
    })
    
    print(f"[JOIN] {name} id={player.player_id} total={len(room.players)}")
    return player


async def handle_start_game(player: Player) -> None:
    if player.player_id != room.host_id():
        await send(player.ws, {"action": "error", "reason": "Apenas o host pode iniciar o jogo."})
        return
    
    if len(room.players) < MIN_PLAYERS:
        await send(player.ws, {"action": "error", "reason": f"Mínimo de {MIN_PLAYERS} jogadores necessário."})
        return
    
    if room.started:
        await send(player.ws, {"action": "error", "reason": "Partida já iniciada."})
        return
    
    room.started = True
    
    await broadcast_all({
        "action": "game_start",
        "players": room.players_payload(),
        "host_id": room.host_id(),
    })
    
    print(f"[GAME] Iniciado pelo host={room.host_id()} com {len(room.players)} jogadores.")


async def handle_relay(player: Player, msg: dict) -> None:
    """Repassa mensagens de jogo sem interpretar o conteúdo."""
    to = msg.get("to", "others")
    payload = {k: v for k, v in msg.items() if k != "to"}
    payload["from_player_id"] = player.player_id
    
    if to == "all":
        await broadcast_all(payload)
    
    elif to == "others":
        await broadcast(payload, exclude=player.player_id)
    
    else:
        try:
            target_id = int(to)
        except (ValueError, TypeError):
            await send(player.ws, {"action": "error", "reason": f"Campo 'to' inválido: {to}"})
            return
        
        target = room.players.get(target_id)
        if target:
            await send(target.ws, payload)
        else:
            await send(player.ws, {"action": "error", "reason": f"Jogador {target_id} não encontrado."})



@app.websocket("/ws")
async def websocket_endpoint(ws: WebSocket):
    await ws.accept()
    player: Player | None = None
    
    try:
        raw = await ws.receive_text()
        msg = json.loads(raw)
        
        if msg.get("action") != "join":
            await send(ws, {"action": "error", "reason": "Primeira mensagem deve ser join."})
            await ws.close()
            return
        
        player = await handle_join(ws, msg)
        if player is None:
            await ws.close()
            return
        
        while True:
            raw = await ws.receive_text()
            msg = json.loads(raw)
            action = msg.get("action", "")
            
            if action == "start_game":
                await handle_start_game(player)
            else:
                await handle_relay(player, msg)
    
    except WebSocketDisconnect:
        pass
    except Exception as e:
        print(f"[ERROR] {e}")
    finally:
        if player:
            room.remove(player.player_id)
            
            if not room.players:
                room.started = False
                room.next_id = 1
                print("[ROOM] Sala resetada.")
            else:
                await broadcast_all({
                    "action": "player_left",
                    "player_id": player.player_id,
                    "name": player.name,
                    "players": room.players_payload(),
                })
                if not room.started:
                    await broadcast_all({
                        "action": "lobby_update",
                        "players": room.players_payload(),
                        "host_id": room.host_id(),
                    })
            
            print(f"[LEAVE] {player.name} id={player.player_id}")