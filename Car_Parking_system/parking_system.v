//CAR PARKING SYSTEM
module car_parking_system( 
                input clk,reset_n,
 input sensor_entrance, sensor_exit, 
 input [1:0] password_1, password_2,
 output wire GREEN_LED,RED_LED,
 output reg [6:0] HEX_1, HEX_2
    );
 parameter Idle = 3'b000, Wait_password = 3'b001, Wrong_password = 3'b010, Right_password = 3'b011,Stop = 3'b100;
 
// Moore FSM
 reg[2:0] current_state, next_state;
 reg[31:0] counter_wait;
 reg red,green;

 // Next state
 always @(posedge clk or negedge reset_n)
 begin
 if(~reset_n) 
 current_state = Idle;
 else
 current_state = next_state;
 end

//Counter wait
always @(posedge clk or negedge reset_n)
begin
if(~reset_n)
counter_wait <= 0;
else if(current_state == Wait_password)
counter_wait <= counter_wait + 1;
else
counter_wait <= 0;
end

//change state
always @(*)
begin
case(current_state)
Idle : begin
if(sensor_entrance == 1)
next_state = Wait_password;
else
next_state = Idle;
end
Wait_password: begin
if(counter_wait <= 3)
next_state = Wait_password;
else
begin
if((password_1 == 2'b01) && (password_2 == 2'b10))
next_state = Right_password;
else
next_state = Wrong_password;
end
end
Wrong_password: begin
if((password_1 == 2'b01) && (password_2 == 2'b10))
next_state = Right_password;
else
next_state = Wrong_password;
end
Right_password: begin
if(sensor_entrance == 1 && sensor_exit == 1)
next_state = Stop;
else if(sensor_exit == 1)
next_state = Idle;
else
next_state = Right_password;
end
Stop: begin
if((password_1 == 2'b01) && (password_2 == 2'b10))
next_state = Right_password;
else
next_state = Stop;
end
default: next_state = Idle;
endcase
end

//LEDs and output
//change the period of blinking LEDs
always @(posedge clk) begin
case(current_state)
Idle: begin
green = 1'b0;
red = 1'b0;
HEX_1 = 7'b1111111;   //OFF
HEX_2 = 7'b1111111;   //OFF
end
Wait_password: begin
green = 1'b0;
red = 1'b1;
HEX_1 = 7'b000_0110; //E
HEX_2 = 7'b010_1011; // n 
 end
 Wrong_password: begin
 green= 1'b0;
 red = ~red;
 HEX_1 = 7'b000_0110; // E
 HEX_2 = 7'b000_0110; // E 
 end
 Right_password: begin
 green = ~green;
 red = 1'b0;
 HEX_1 = 7'b000_0010; // 6
 HEX_2 = 7'b100_0000; // 0 
 end
 Stop: begin
 green = 1'b0;
 red = ~red;
 HEX_1 = 7'b001_0010; // 5
 HEX_2 = 7'b000_1100; // P 
 end
 endcase
 end
 assign RED_LED = red ;
 assign GREEN_LED = green;
endmodule





