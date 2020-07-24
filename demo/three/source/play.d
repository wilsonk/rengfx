module play;

import re;
import re.gfx;
import re.math;
static import raylib;
import things;

class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        auto cam = &camera;
        cam.position = Vector3(0, 10, 10);
        camera.target = Vector3(0, 0, 0);
        camera.up = Vector3(0, 1, 0);
        camera.fovy = 45;
        camera.type = CameraType.CAMERA_PERSPECTIVE;
        raylib.SetCameraMode(camera, raylib.CameraMode.CAMERA_ORBITAL);

        auto block = create_entity("block", Vector3(0, 0, 0));
        block.add_component!Cube();

        auto grid = create_entity("grid");
        grid.add_component!Grid();
    }
}
