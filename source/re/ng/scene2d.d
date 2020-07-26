module re.ng.scene2d;

static import raylib;
public import raylib : Camera2D;
import re.ng.camera;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a scene rendered in 2d
abstract class Scene2D : Scene {
    /// the 2d scene camera
    public SceneCamera2D cam;
    /// the camera entity
    public Entity camera_nt;

    override void setup() {
        super.setup();

        // create a camera entity
        camera_nt = create_entity("camera");
        cam = camera_nt.add_component(new SceneCamera2D());
    }

    override void render_scene() {
        raylib.BeginMode2D(cam.camera);

        // render 2d components
        foreach (component; ecs.storage.renderable_components) {
            auto renderable = cast(Renderable2D) component;
            assert(renderable !is null, "renderable was not 2d");
            renderable.render();
            if (Core.debug_render) {
                renderable.debug_render();
            }
        }

        raylib.EndMode2D();
    }
}
