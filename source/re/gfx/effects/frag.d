module re.gfx.effects.frag;

import re.ng.scene;
import re.gfx.raytypes;
import re.gfx.effect;
static import raylib;

/// fragment shader effect
class FragEffect : Effect {
    enum shader_uni_resolution = "i_resolution";
    enum shader_uni_frame = "i_frame";
    enum shader_uni_time = "i_time";
    // enum shader_uni_mouse = "i_mouse";

    Scene scene;
    int start_frame = 0;
    float start_time = 0;

    this(Scene scene, Shader shader) {
        super(shader, Colors.WHITE);
        this.scene = scene;

        // initialize uniforms
        init_time();
        sync_uniforms();
    }

    public void init_time() {
        start_frame = Time.frame_count;
        start_time = Time.total_time;
    }

    public void sync_uniforms() {
        this.set_shader_var_imm(shader_uni_resolution, cast(float[3])[
                scene.resolution.x, scene.resolution.y, 1.0
            ]);

    }

    public void update() {
        this.set_shader_var_imm(shader_uni_frame, cast(int)(Time.frame_count - start_frame));
        this.set_shader_var_imm(shader_uni_time, Time.total_time - start_time);
    }
}
