module re.ng.scene;

import re;
import std.string;
import re.ecs;
import re.gfx;
import re.math;
static import raylib;

public {
    import re.time;
    import re.ng.scene2d;
    import re.ng.scene3d;
}

/// represents a collection of entities that draw to a texture
abstract class Scene {
    /// the cleared background color
    public raylib.Color clear_color;
    /// the entity manager
    public EntityManager ecs;
    /// the render target
    public RenderTarget render_target;
    private Vector2 _resolution;
    /// the mode of compositing
    public CompositeMode composite_mode;
    /// postprocessors effects
    public PostProcessor[] postprocessors;

    /// the mode for compositing a scene onto the display buffer
    public struct CompositeMode {
        /// the texture render tint color
        raylib.Color color = raylib.Colors.WHITE;
    }

    /// creates a new scene
    this() {
    }

    /// gets the render resolution. initialized to Core.default_resolution
    @property Vector2 resolution() {
        return _resolution;
    }

    /// sets the render resolution and updates the render target
    @property Vector2 resolution(Vector2 value) {
        _resolution = value;
        update_render_target();
        return value;
    }

    /// sets the texture filtering mode for the scene render target
    @property raylib.TextureFilterMode filter_mode(raylib.TextureFilterMode value) {
        // texture scale filter
        raylib.SetTextureFilter(render_target.texture, value);
        return value;
    }

    /// called at the start of the scene
    protected void on_start() {

    }

    /// called right before cleanup
    protected void unload() {

    }

    /// called internally to update ecs
    public void update() {
        // update ecs
        ecs.update();

        // update components
        foreach (component; ecs.storage.updatable_components) {
            auto updatable = cast(Updatable) component;
            updatable.update();
        }
    }

    /// called internally to render ecs
    public void render() {
        raylib.BeginTextureMode(render_target);
        raylib.ClearBackground(clear_color);

        render_scene();

        raylib.EndTextureMode();
    }

    /// run postprocessors
    public void post_render() {
        import std.algorithm : filter;
        import std.array : array;

        auto pipeline = postprocessors.filter!(x => x.enabled).array;
        // skip if no postprocessors
        if (pipeline.length == 0)
            return;

        pipeline[0].process(render_target);
        auto last_buf = pipeline[0].buffer;
        for (auto i = 1; i < pipeline.length; i++) {
            auto postprocessor = pipeline[i];
            postprocessor.process(last_buf);
            last_buf = postprocessor.buffer;
        }
        // draw the last buf in the chain to the main texture
        RenderExt.draw_render_target_from(last_buf, render_target);
    }

    protected abstract void render_scene();

    private void update_render_target() {
        if (Core.headless)
            return;
        // free any old render target
        if (render_target == raylib.RenderTexture2D.init) {
            raylib.UnloadRenderTexture(render_target);
        }
        // create render target
        // TODO: use scene resolution instead of window resolution
        render_target = raylib.LoadRenderTexture(cast(int) resolution.x, cast(int) resolution.y);
    }

    /// called internally on scene creation
    public void begin() {
        setup();

        on_start();
    }

    /// setup that hapostprocessorsens after begin, but before the child scene starts
    protected void setup() {
        // set up ecs
        ecs = new EntityManager;

        resolution = Core.default_resolution;
    }

    /// called internally on scene destruction
    public void end() {
        unload();

        ecs.destroy();
        foreach (postprocessor; postprocessors) {
            postprocessor.destroy();
        }

        if (!Core.headless) {
            // free render target
            raylib.UnloadRenderTexture(render_target);
        }
    }

    // - ecs

    /// create an entity given a name
    public Entity create_entity(string name) {
        auto nt = ecs.create_entity();
        nt.name = name;
        return nt;
    }

    /// create an entity given a name and a 2d position
    public Entity create_entity(string name, Vector2 pos = Vector2(0, 0)) {
        auto nt = create_entity(name);
        nt.position2 = pos;
        return nt;
    }

    /// create an entity given a name and a 3d position
    public Entity create_entity(string name, Vector3 pos = Vector3(0, 0, 0)) {
        auto nt = create_entity(name);
        nt.position = pos;
        return nt;
    }

    public Entity get_entity(string name) {
        return ecs.get_entity(name);
    }
}

@("scene-lifecycle")
unittest {
    class TestScene : Scene2D {
        override void on_start() {
            auto apple = create_entity("apple");
            assert(get_entity("apple") == apple, "could not get entity by name");
        }
    }

    Core.headless = true;
    auto scene = new TestScene();
    scene.begin();
    scene.update();
    scene.end();
}

@("scene-load")
unittest {
    class TestScene : Scene2D {
    }

    Core.headless = true;

    auto scene = new TestScene();
    Core.load_scenes([scene]);
    assert(Core.get_scene!TestScene == scene);
}