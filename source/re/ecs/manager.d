/** internal orhestration of entity/component system */

module re.ecs.manager;

import re.ecs.entity;
import re.ecs.component;
import re.ecs.storage;
import std.algorithm;
import std.array;

/// manages the entity/component system
class EntityManager {
    /// list of all entities
    public Entity[] entities;
    /// helper to store components in an optimized way
    public ComponentStorage storage;
    private size_t[] entities_to_remove;
    private size_t entity_counter;

    /// sets up the ECS
    this() {
        storage = new ComponentStorage(this);
    }

    /// create a fresh entity
    public Entity create_entity() {
        auto nt = new Entity(this);
        nt.initialize();
        nt.id = entity_counter++;
        entities ~= nt;
        return nt;
    }

    public Entity get_entity(string name) {
        auto list = entities.find!(x => x.name == name);
        if (list.length == 0) {
            assert(0, "no matching entity was found");
        }
        return list[0];
    }

    public bool has_entity(string name) {
        return entities.any!(x => x.name == name);
    }

    /// remove an entity
    public void remove_entity(Entity entity) {
        entities.remove!(x => x == entity);
        // TODO: entity pooling
    }

    /// keeps all the ducks in line
    public void update() {
        entities_to_remove = [];
        for (size_t i = 0; i < entities.length; i++) {
            auto nt = entities[i];
            if (!nt.alive) {
                entities_to_remove ~= i;
            }
        }

        // remove entities
        foreach (to_remove; entities_to_remove) {
            entities = remove(entities, to_remove);
        }
    }

    /// destroy all entities and components and clean up
    public void destroy() {
        foreach (entity; entities) {
            entity.destroy();
        }
    }
}

@("ecs-basic")
unittest {
    class Food : Component {
        public bool tasty = true;
    }

    auto ecs = new EntityManager();
    auto nt = ecs.create_entity();
    auto food = new Food();
    nt.add_component(food);
    assert(nt.has_component!Food, "component was not properly added");
    assert(nt.get_component!Food == food, "component cannot be retrieved");
    nt.remove_component!Food();
    assert(!nt.has_component!Food, "component cannot be removed");
    nt.destroy();
    assert(!nt.alive);
}

@("ecs-destroy")
unittest {
    static class Thing1 : Component {
    }

    static class Thing2 : Component {
    }

    auto ecs = new EntityManager();
    auto nt1 = ecs.create_entity();
    nt1.add_component!Thing1();
    auto nt2 = ecs.create_entity();
    nt2.add_component!Thing2();

    ecs.destroy();
}

@("ecs-test1")
unittest {
    class Butter : Component {
        public bool tasty = true;
    }

    class Jelly : Component {
        public int rank = 4;
    }

    auto ecs = new EntityManager();
    auto sandwich1 = ecs.create_entity();
    auto sandwich2 = ecs.create_entity();
    auto sandwich3 = ecs.create_entity();

    sandwich1.add_component(new Butter());
    sandwich1.add_component(new Jelly());
    assert(sandwich1.has_component!Butter);
    assert(sandwich1.has_component!Jelly);

    sandwich2.add_component(new Butter());
    assert(sandwich2.has_component!Butter);

    sandwich3.add_component(new Jelly());
    assert(sandwich3.has_component!Jelly);

    sandwich1.remove_component!Butter;

    // make sure everything else is still good
    enum msg = "component storage is unstable";
    assert(!sandwich1.has_component!Butter, msg);
    assert(sandwich1.has_component!Jelly, msg);
    assert(sandwich2.has_component!Butter, msg);
    assert(sandwich3.has_component!Jelly, msg);

    ecs.destroy();
}

@("ecs-test2")
unittest {
    import re.ecs : Renderable, Updatable;

    static class Brush : Component, Renderable {
        void render() {
        }

        void debug_render() {
        }
    }

    static class Control : Component {
    }

    static class Paint : Component, Updatable {
        void update() {
        }
    }

    auto ecs = new EntityManager();

    auto a1 = ecs.create_entity();
    a1.add_component!Brush(); // R
    a1.add_component!Control(); // B
    a1.add_component!Paint(); // U

    ecs.destroy();
}
