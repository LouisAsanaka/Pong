import java.util.Map;

int static final WINDOW_WIDTH = 400;
int static final WINDOW_HEIGHT = 300;

int static final PADDLE_WIDTH = 50;
int static final PADDLE_HEIGHT = 10;

int static final PADDLE_MAX_SPEED = -1;
int static final CPU_PADDLE_SPEED = PADDLE_MAX_SPEED;
int static final PLAYER_PADDLE_SPEED = 4;

int static final BALL_SPEED = 3;
int static final BALL_SIZE = 5;

boolean restartGame = false;
int restartTime;

HashMap<Integer, Boolean> keys;

Player p;
Computer cpu;
Ball matchBall;

void setup() {
    size(400, 300);
    surface.setResizable(true);
    surface.setSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    
    frameRate(60);
    
    keys = new HashMap<Integer, Boolean>();

    p = new Player();
    cpu = new Computer();
    matchBall = new Ball(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2);
}

void update() {
    p.update();
    cpu.update(matchBall);
    matchBall.update(p.paddle, cpu.paddle);
}

void render() {
    background(#DCDCDC);
    p.render();
    cpu.render();
    matchBall.render();
}

void draw() {
    if(restartGame){
        //background(#DCDCDC);
        if (millis() - restartTime > 3000) {
            restartGame = false;
        } else {
            textAlign(CENTER, CENTER);
            textSize(64);
            fill(#FF0000);
            text("Game over!", WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2);
        }
        return;
    }
    update();
    render();
}

class Player {
    Paddle paddle;
    
    Player() {
        this.paddle = new Paddle(WINDOW_WIDTH / 2 - PADDLE_WIDTH / 2, WINDOW_HEIGHT - PADDLE_HEIGHT * 2, PADDLE_WIDTH, PADDLE_HEIGHT);   
    }
    
    void render() {
        this.paddle.render(); 
    }
    
    void update() {
        for (int key : keys.keySet()) {
            if (key == LEFT) {
                this.paddle.move(-PLAYER_PADDLE_SPEED, 0);
            } else if (key == RIGHT) {
                this.paddle.move(PLAYER_PADDLE_SPEED, 0);
            } else {
                this.paddle.move(0, 0);
            }
        }   
    }
}

class Computer {
    Paddle paddle;
    
    Computer() {
        this.paddle = new Paddle(WINDOW_WIDTH / 2 - PADDLE_WIDTH / 2, PADDLE_HEIGHT, PADDLE_WIDTH, PADDLE_HEIGHT);
    }
    
    void render() {
        this.paddle.render();   
    }
    
    void update(Ball ball) {
        int x_pos = ball.x;
        int diff = -((this.paddle.x + (this.paddle.width / 2)) - x_pos);
        
        if (CPU_PADDLE_SPEED != -1) {
            if (diff < 0 && diff < -CPU_PADDLE_SPEED) {
                diff = -CPU_PADDLE_SPEED;
            } else if (diff > 0 && diff > CPU_PADDLE_SPEED) {
                diff = CPU_PADDLE_SPEED;
            }
        }
        this.paddle.move(diff, 0);
        if (this.paddle.x < 0) {
            this.paddle.x = 0;
        } else if (this.paddle.x + this.paddle.width > WINDOW_WIDTH) {
            this.paddle.x = WINDOW_WIDTH - this.paddle.width;
        } 
    }
}

class Ball {
    int x, y, x_speed, y_speed;
    
    Ball(int x, int y) {
        this.x = x;
        this.y = y;
        this.x_speed = 0;
        this.y_speed = BALL_SPEED;   
    }
    
    void render() {
        fill(#000000);
        ellipse(this.x, this.y, BALL_SIZE, BALL_SIZE);   
    }
    
    void update(Paddle paddle1, Paddle paddle2) {
        this.x += this.x_speed;
        this.y += this.y_speed;
        int top_x = this.x - BALL_SIZE;
        int top_y = this.y - BALL_SIZE;
        int bottom_x = this.x + BALL_SIZE;
        int bottom_y = this.y + BALL_SIZE;
    
        if (this.x - BALL_SIZE < 0) {
            this.x = BALL_SIZE;
            this.x_speed = -this.x_speed;
        } else if (this.x + BALL_SIZE > WINDOW_WIDTH) {
            this.x = WINDOW_WIDTH - BALL_SIZE;
            this.x_speed = -this.x_speed;
        }
    
        if (this.y < 0 || this.y > WINDOW_HEIGHT) {
            this.x_speed = 0;
            this.y_speed = BALL_SPEED;
            
            this.x = WINDOW_WIDTH / 2;
            this.y = WINDOW_HEIGHT / 2;

            restartGame = true;
            restartTime = millis();
            return;
        }
    
        if (top_y > WINDOW_HEIGHT / 2) {
            if (top_y < (paddle1.y + paddle1.height) && bottom_y > paddle1.y && top_x < (paddle1.x + paddle1.width) && bottom_x > paddle1.x) {
                this.y_speed = -BALL_SPEED;
                this.x_speed += (paddle1.x_speed / 2);
                this.y += this.y_speed;
            }
        } else {
            if (top_y < (paddle2.y + paddle2.height) && bottom_y > paddle2.y && top_x < (paddle2.x + paddle2.width) && bottom_x > paddle2.x) {
                this.y_speed = BALL_SPEED;
                this.x_speed += (paddle2.x_speed / 2);
                this.y += this.y_speed;
            }
        }
    }
}

class Paddle {
    int x, y, width, height, x_speed, y_speed;
    
    Paddle(int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.x_speed = 0;
        this.y_speed = 0;
    }
    
    void render() {
        fill(#0000FF);
        rect(this.x, this.y, this.width, this.height);
    }
    
    void move(int x, int y) {
        this.x += x;
        this.y += y;
        this.x_speed = x;
        this.y_speed = y;
        if (this.x < 0) {
            this.x = 0;
            this.x_speed = 0;
        } else if (this.x + this.width > WINDOW_WIDTH) {
            this.x = WINDOW_WIDTH - this.width;
            this.x_speed = 0;
        }
    }
}

void keyPressed() {
    keys.put(keyCode, true);
}
 
void keyReleased() {
    keys.remove(keyCode);
}
