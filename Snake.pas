uses CRT;

type
  DirectionEnum = (Up, Right, Down, Left);
  
  Vector2I = record
  private 
    X: integer;
    Y: integer;
  
  public 
    constructor Create(px, py: integer);
    begin
      Self.Init(px, py);
    end;
    
    procedure Init(px, py: integer);
    begin
      Self.X := px;
      Self.Y := py;
    end;
  end;
  
  GameObject = class
    class function Collides(var A, B: Vector2I) := (A.X = B.X) and (A.Y = B.Y);
    class function Contains(var list: array of Vector2I; var crd: Vector2I): boolean;
    begin
      if list.Contains(crd) then begin
        result := true;
        exit();
      end;
      
      for var i := 0 to Length(list) - 1 do 
      begin
        if ((abs(list[i].X - crd.X) <= 1) and (abs(list[i].Y - crd.Y) <= 1))
        then begin
          result := true;
          exit();
        end;
      end;
      
      result := false;
    end;
    
    class function GenRandCoords(var list: array of Vector2I): Vector2I;
    begin
      var crd: Vector2I;
      crd := new Vector2I(random(CRT.WindowWidth() - 4) + 4, random(CRT.WindowHeight() - 5) + 3);
      
      while (GameObject.Contains(list, crd) or (crd.X mod 2 = 0)) do 
      begin
        crd := new Vector2I(random(CRT.WindowWidth() - 4) + 4, random(CRT.WindowHeight() - 5) + 3);  
      end;
      result := crd;
    end;
  end;
  
  SnakeClass = class
  private 
    Body: array of Vector2I;
    Direction: DirectionEnum;
    Alive: boolean;
    Color: integer;
    Symbol: char;
    
    procedure SetDirection(dir: DirectionEnum);
    begin
      if abs(ord(Self.Direction) - ord(dir)) <> 2 then
        Self.Direction := dir;
    end;
    
    procedure Die();
    begin
      Self.Alive := false
    end;
    
    procedure ShiftBody();
    begin
      for var i := Self.GetLength() - 1 downto 1 do 
      begin
        Self.Body[i] := Self.Body[i - 1];
      end;
      writeln();
    end;
    
    procedure ShiftHead();
    begin
      case Self.Direction of 
        DirectionEnum.Up: Self.Body[0].Y -= 1;
        DirectionEnum.Right: Self.Body[0].X += 2;
        DirectionEnum.Down: Self.Body[0].Y += 1;
        DirectionEnum.Left: Self.Body[0].X -= 2;
      end;
    end;
    
    procedure Move();
    begin
      Self.ShiftBody();
      Self.ShiftHead();
    end;
  
  public 
    constructor Create(coords: Vector2I; dir: DirectionEnum);
    begin
      var initLength := 5;
      
      Self.Color := CRT.Green;
      Self.Direction := dir;
      Self.Symbol := 'O';
      
      Self.Alive := true;
      
      SetLength(Self.Body, 1);
      Self.Body[0] := coords;
      
      for var i := 1 to initLength do 
      begin
        SetLength(Self.Body, Self.GetLength() + 1);
        Self.Move();
      end;
    end;
    
    function IsAlive()  := Self.Alive;    
    function GetLength()  := Self.Body.Length;
    function GetDirection()  := Self.Direction;
    function Collides(): boolean;
    begin
      for var i := 1 to Self.Body.Length - 1 do 
        if GameObject.Collides(Self.Body[0], Self.Body[i]) then begin
          Result := true;
          exit();
        end;
      
      if (Self.Body[0].X <= 2) or (Self.Body[0].X >= CRT.WindowWidth())
        or (Self.Body[0].Y <= 2) or (Self.Body[0].Y >= CRT.WindowHeight() - 2)
        then 
      begin
        Result := true;
        exit();
      end;
      
      Result := false;
    end;
    
    procedure SetColor(code: integer);
    begin
      if code in [0..15] then
        Self.Color := code;
    end;
    
    procedure SetSymbol(sym: char);
    begin
      Self.Symbol := sym;
    end;
    
    procedure Push(coords: Vector2I);
    begin
      SetLength(Self.Body, Self.GetLength() + 1);
      Self.Body[Self.GetLength() - 1] := coords;
    end;
    
    procedure Render();
    begin
      TextColor(Self.Color);
      
      for var i := 0 to Self.GetLength() - 1 do 
      begin
        CRT.GoToXY(Self.Body[i].X, Self.Body[i].Y);
        write(Self.Symbol);
      end;
    end;
    
    procedure Update();
    begin
      Self.Move();
      
      if Self.Collides() then begin
        Self.Die();
        exit();
      end;
      
      Self.Render();
    end;
  end;
  
  FieldClass = class
  private 
    Size: Vector2I;
    Symbol: char;
    BgColor: integer;
    BorderColor: integer;
    ScoresColor: integer;  
    
  public 
    constructor Create();
    begin
      Self.BgColor := CRT.Black;
      Self.BorderColor := CRT.White;
      Self.Symbol := '*';
      Self.ScoresColor := CRT.Cyan;
    end;
    
    function GetSize()  := Self.Size;
    procedure Render();
    begin
      CRT.TextColor(Self.BorderColor);
      
      for var x := 2 to Self.Size.X do 
      begin
        if x mod 2 = 0 then begin
          CRT.GotoXY(x, 2);
          write(Self.Symbol);
          
          CRT.GotoXY(x, Self.Size.Y);
          write(Self.Symbol);
        end;
      end;
      
      for var y := 2 to Self.Size.Y do 
      begin
        CRT.GotoXY(2, y);
        write(Self.Symbol);
        
        CRT.GotoXY((Self.Size.X mod 2 = 0) ? Self.Size.X : Self.Size.X - 1, y);
        write(Self.Symbol);
      end;
      CRT.GotoXY(1, 1);
    end;
    procedure Init(w, h: integer);
    begin
      var offset := new Vector2I(0, 2);
      Self.Size := new Vector2I(w - offset.X, h - offset.Y);
      
      CRT.SetWindowSize(w, h);
      CRT.SetWindowCaption('Snake Game');
      CRT.HideCursor();
    end;
    procedure ClearSequence(coord: Vector2I);
    begin
      CRT.TextColor(Self.BgColor);
      GoToXY(coord.X, coord.Y);
      write(' ');
    end;
    procedure RenderScores(scores: integer);
    begin
      CRT.TextColor(Self.ScoresColor);
      CRT.GotoXY(2, CRT.WindowHeight() - 1);
      
      write('Scores: ', scores);
    end;
  end;
  
  FoodSetClass = class
  private 
    Coords: array of Vector2I;
    Symbol: char;
    Color: integer;
    Count: integer;
  
  public 
    constructor Create(foodCount: integer);
    begin
      Self.Symbol := '@';
      Self.Color := CRT.Red;
      Self.Count := foodCount;
      
      SetLength(Self.Coords, foodCount);
      
      for var i := 0 to foodCount - 1 do 
      begin
        Self.Coords[i] := GameObject.GenRandCoords(Self.Coords);
      end;
    end;
    
    function GetCount()  := Self.Count;
    procedure Render();
    begin
      CRT.TextColor(Self.Color);
      for var i := 0 to Self.GetCount() - 1 do 
      begin
        CRT.GotoXY(Self.Coords[i].X, Self.Coords[i].Y);
        write(Self.Symbol);
      end;
    end;
  end;
  
  GameClass = class
  private 
    Snake: SnakeClass;
    Field: FieldClass;
    Delay: integer;
    Food: FoodSetClass;
    Scores: integer;
  
  public 
    constructor Create();
    begin
      Self.Field := new FieldClass();
      Self.Field.Init(100, 30);
      Self.Field.Render();
      Self.Snake := new SnakeClass(new Vector2I(5, 5), DirectionEnum.Down);
      Self.Food := new FoodSetClass(10);
      Self.Delay := 100;
      Self.Scores := 0;
    end;
    
    function IsAlive()  := Self.Snake.IsAlive();
    
    procedure Arrive();
    begin
      CRT.ClrScr();
      CRT.TextColor(CRT.Yellow);
      CRT.GotoXY(CRT.WindowWidth() div 2, CRT.WindowHeight() div 2);
      write('Game Over');
      CRT.TextColor(CRT.Magenta);
      CRT.GotoXY(CRT.WindowWidth() div 2 - 2, CRT.WindowHeight() div 2 + 2);
      write('Your Scores: ', Self.Scores);
      CRT.TextColor(Self.Field.BgColor);
    end;
    
    procedure HandleFoodCollisions();
    begin
      for var i := 0 to Length(Self.Food.Coords) - 1 do 
      begin
        if GameObject.Collides(Self.Food.Coords[i], Self.Snake.Body[0]) then begin
          Self.Snake.Push(Self.Food.Coords[i]);
          Self.Food.Coords[i] := GameObject.GenRandCoords(Self.Food.Coords);
          Self.Scores += 1;
        end;
      end;
    end;
    
    procedure ReadKeys();
    begin
      if CRT.KeyPressed() then begin
        var keyCode := CRT.ReadKey();
        
        case keyCode of
          'W', 'w', 'Ц', 'ц': Self.Snake.SetDirection(DirectionEnum.Up);
          'D', 'd', 'В', 'в': Self.Snake.SetDirection(DirectionEnum.Right);
          'S', 's', 'Ы', 'ы': Self.Snake.SetDirection(DirectionEnum.Down);
          'A', 'a', 'Ф', 'ф': Self.Snake.SetDirection(DirectionEnum.Left);
        end;
      end;
    end;
    
    procedure Update();
    begin
      Self.Field.ClearSequence(Self.Snake.Body[Self.Snake.GetLength() - 1]);
      Self.Field.RenderScores(Self.Scores);
      Self.HandleFoodCollisions();
      Self.Food.Render();
      Self.ReadKeys();
      Self.Snake.Update();
      CRT.Delay(Self.Delay);
    end;
    
    procedure Start();
    begin
      while Self.IsAlive() do 
        Self.Update();
      Self.Arrive();
    end;
  end;

begin
  repeat
    var Game := new GameClass();
    Game.Start();
    readkey();
    CRT.ClrScr();
  until false;
end.