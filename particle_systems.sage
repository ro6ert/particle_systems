#To Run
#sage particle_systems.sage
import random
from sage.plot.plot3d.shapes import *
from sage.plot.plot3d.shapes2 import Line
from sage.plot.plot3d.shapes2 import line3d

linear_rotation = "linear rotation"
linear_attractor = "linear attractor"
linear_rotation_with_attractor = "linear rotation with attractor"
brownean = "brownean"
browneanSpherical = "browneanSpherical"
browneanCylindrical = "browneanCylindrical"
browneanManifold = "browneanManifold"

class particle(object):
    """a particle"""
    def __init__(self, **kwargs):
        self.dimensions = kwargs.get("dimensions")
        self.forcefields = kwargs.get("forcefields")
        self.color = kwargs.get("color")
        self.history = []
        for forcefield in self.forcefields:
            forcefield.register_particle(self)

    def spherical_normalize(self):
        x = self.dimensions["x"]
        y = self.dimensions["y"]
        z = self.dimensions["z"]
        radius = self.dimensions["r"]
        rnorm=sqrt(x**2+y**2+z**2)/radius
        self.dimensions["x"] = x/rnorm
        self.dimensions["y"] = y/rnorm
        self.dimensions["z"] = z/rnorm

    def cylindrical_normalize(self):
        x = self.dimensions["x"]
        y = self.dimensions["y"]
        z = self.dimensions["z"]
        radius = self.dimensions["r"]
        rnorm = sqrt(x**2+y**2)/radius
        self.dimensions["x"] = x/rnorm
        self.dimensions["y"] = y/rnorm
        self.dimensions["z"] = z

    def manifold_normalize(self): #fixme
        x = self.dimensions["x"]
        y = self.dimensions["y"]
        z = self.dimensions["z"]
        #minimize distance to a given manifold. (Fixme)
        x_new = x
        y_new = y
        z_new = z
        self.dimensions["x"] = x_new
        self.dimensions["y"] = y_new
        self.dimensions["z"] = z_new

    def normalize(self):
        if False:
            self.spherical_normalize()
        elif True:
            self.cylindrical_normalize()
        elif False:
            self.manifold_normalize()

    def move(self):
        self.history.append({"x":self.dimensions["x"], "y":self.dimensions["y"], "z":self.dimensions["z"]})
        for field in self.forcefields:
            self.dimensions.update(field.perturb(self.dimensions))
        self.normalize()

class field(object):
    """a field object"""
    def __init__(self):
        self.particles = []

    def deform(self):
        pass

    def register_particle(self, particle):
        self.particles.append(particle)

    def force_at_location(self, dimensions):
        return {"vx":0, "vy":0, "vz":0}

    def perturb(self, dimensions):
        newdimensions = {}
        newdimensions.update(dimensions)
        force_at_location_freeze=self.force_at_location(dimensions)
        for xi, vxi in [("x","vx"), ("y","vy"), ("z", "vz")]:
            if xi in dimensions and vxi in dimensions:
                xi_new = dimensions[xi] + dimensions[vxi]
                newdimensions[xi] = xi_new
                vxi_new = dimensions[vxi]+force_at_location_freeze.get(vxi)
                newdimensions[vxi] = vxi_new
        return newdimensions

class linearRotationField(field):
    """linear rotation"""
    def force_at_location(self, dimensions):
        dt = .1
        return {"vx":-dimensions.get("y")*dt, "vy":dimensions.get("x")*dt, "vz":0}

class linearRotationFieldWithAttractor(field):
    """linear rotation with attractor"""
    def force_at_location(self, dimensions):
        dt = .1
        dr = 1/(dimensions.get("x")**2+dimensions.get("y")**2)**.5
        return {"vx":(-dimensions.get("y")-2*dimensions.get("x"))*dt*dr, "vy":(dimensions.get("x")-2*dimensions.get("y"))*dt*dr, "vz":0}

class linearAttractor(field):
    """linear rotation with attractor"""
    def force_at_location(self, dimensions):
        dt = .1
        dr = 1/(dimensions.get("x")**2+dimensions.get("y")**2)**.5
        return {"vx":(-dimensions.get("x"))*dt*dr, "vy":(-dimensions.get("y"))*dt*dr, "vz":0}


class browneanField(field):
    """brownean"""
    def force_at_location(self, dimensions):
        dt = .1
        dx = random.gauss(0,1)
        dy = random.gauss(0,1)
        dz = random.gauss(0,1)
        return {"vx":dx*dt, "vy":dy*dt, "vz":dz*dt}

class browneanSphericalField(field):
    """brownean spherical"""
    def force_at_location(self, dimensions):
        dt = 0.1
        sigma=5
        dx = random.gauss(0,sigma)
        dy = random.gauss(0,sigma)
        dz = random.gauss(0,sigma)
        x = dimensions.get("x")
        y = dimensions.get("y")
        z = dimensions.get("z")
        vx = dimensions.get("vx")
        vy = dimensions.get("vy")
        vz = dimensions.get("vz")
        xperturb = dx*dt
        yperturb = dy*dt
        zperturb = dz*dt
        #also need to cancel the radius by adding this: r/|r|-r
        rnorm = sqrt(x**2 + y**2 + z**2)
        print(f"rnorm={rnorm}")
        xnew = 50*xperturb/rnorm
        ynew = 50*yperturb/rnorm
        znew = 50*zperturb/rnorm
        return {"vx":dx-vx, "vy":dy-vy, "vz":dz-vz}

class browneanCylindricalField(field):
    """brownean cylindrical"""
    def force_at_location(self, dimensions):
        dt = 0.1
        sigma=5
        dx = random.gauss(0,sigma)
        dy = random.gauss(0,sigma)
        dz = random.gauss(0,sigma)
        x = dimensions.get("x")
        y = dimensions.get("y")
        z = dimensions.get("z")
        vx = dimensions.get("vx")
        vy = dimensions.get("vy")
        vz = dimensions.get("vz")
        xperturb = dx*dt
        yperturb = dy*dt
        zperturb = dz*dt
        #also need to cancel the radius by adding this: r/|r|-r
        rnorm = sqrt(x**2 + y**2)
        print(f"rnorm={rnorm}")
        xnew = 50*xperturb/rnorm
        ynew = 50*yperturb/rnorm
        znew = zperturb
        return {"vx":dx-vx, "vy":dy-vy, "vz":dz-vz}

class browneanManifoldField(field):
    """brownean manifold"""
    def force_at_location(self, dimensions):
        dt = 0.1
        sigma=5
        dx = random.gauss(0,sigma)
        dy = random.gauss(0,sigma)
        dz = random.gauss(0,sigma)
        x = dimensions.get("x")
        y = dimensions.get("y")
        z = dimensions.get("z")
        vx = dimensions.get("vx")
        vy = dimensions.get("vy")
        vz = dimensions.get("vz")
        xperturb = dx*dt
        yperturb = dy*dt
        zperturb = dz*dt
        #get info from manifold curvature.
        xnew = xperturb
        ynew = yperturb
        znew = zperturb
        return {"vx":dx-vx, "vy":dy-vy, "vz":dz-vz}

class flatField(field):
    """flat field"""
    pass

class forceFieldFactory(object):
    """Creates a field"""
    def __init__(self, **kwargs):
        self.forcefield_type = kwargs.get("forcefield_type")

    def newField(self):
        if self.forcefield_type == linear_rotation:
            return linearRotationField()
        elif self.forcefield_type == linear_rotation_with_attractor:
            return linearRotationFieldWithAttractor()
        elif self.forcefield_type == brownean:
            return browneanField()
        elif self.forcefield_type == browneanSpherical:
            return browneanSphericalField()
        elif self.forcefield_type == browneanCylindrical:
            return browneanCylindricalField()
        elif self.forcefield_type == browneanManifold:
            return browneanManifoldField()
        else:
            return flatField()

class particleFactory(object):
    def __init__(self, **kwargs):
        self.forcefields = kwargs.get("forcefields")
        self.timeout = kwargs.get("timeout")
        self.color = kwargs.get("color","blue")
        self.radius = kwargs.get("radius",50)
        self.forcefield_type_list = kwargs.get("forcefield_type_list")

    def newParticle(self):
        dimensions = {"x":random.random()*100-50, "y":random.random()*100-50, "z":random.random()*100-50, "vx":0, "vy":0, "vz":0, "m":1, "r":self.radius}    
        mote = particle(dimensions=dimensions, forcefields=self.forcefields, color=self.color)
        return mote

class particle_systems(object):
    """Shows Particle Systems"""
    particle_list = []
    field_list = []

    def visualize_frame(self):
        """Visualize a particle system"""
        frame = Graphics()
        frame3d = sage.plot.plot3d.base.Graphics3d()
        frame.axes(False)
        frame3dtrail = sage.plot.plot3d.base.Graphics3d()
        for particle in self.particle_list:
            x = particle.dimensions.get("x")
            y = particle.dimensions.get("y")
            z = particle.dimensions.get("z", 0)
            color=particle.color
            size = particle.dimensions.get("m")
            d = disk((x,y), size, (0, 2*pi), color=color)
            d.axes(False)
            frame += d
            sphere3d = sage.plot.plot3d.shapes2.sphere(center=(x,y,z), size=size, color=color, aspect_ratio=[1,1,1])
            frame3d += sphere3d
            print(f"particle.history = {particle.history}")
            eventlist = [(event.get("x"), event.get("y"), event.get("z")) for event in particle.history][1:]
            print(f"len(eventlist) = {len(eventlist)}")
            if len(eventlist) > 1:
                zipped_eventlist = [eventpair for eventpair in zip(eventlist, [(0,0,0)]+eventlist)][1:]
                # print(eventlist)
                b = line3d(eventlist, thickness=1, opacity=1, aspect_ratio=1, color=color)
                frame3dtrail+=b
                # print(b)
                # b = line(eventlist)
        frame.axes(False)
        return frame,frame3d,frame3dtrail

    def __init__(self, field_config_dict, particle_config_list):
        """Initializes an object"""
        for profile in field_config_dict:
            forcefield_type = field_config_dict.get(profile).get("forcefield_type", linear_rotation)
            force_field_factory = forceFieldFactory(forcefield_type=forcefield_type)
            forcefield = force_field_factory.newField()
            field_config_dict[profile]["forcefield"] = forcefield

        for profile in particle_config_list:
            forcefield_type_list = profile.get("forcefield_type_list")
            timeout = profile.get("timeout", 1)
            number_particles = profile.get("number_particles", 100)
            color = profile.get("color", "blue")
            radius = profile.get("radius",50)
            print(f"forcefield_type_list={forcefield_type_list}")
            forcefields = [field_config_dict.get(forcefield_type).get("forcefield") for forcefield_type in forcefield_type_list]
            particle_factory = particleFactory(forcefields=forcefields, timeout=timeout, color=color, radius=radius, forcefield_type_list=forcefield_type_list)
            for i in range(0, number_particles):
                particle = particle_factory.newParticle()
                self.particle_list.append(particle)

    def act(self):
        for particle in self.particle_list:
            particle.move()
        for field in self.field_list:
            field.deform()

def main():
    #plotname="test_3nsov2023"
    #plotname="brownean"
    #plotname="browneanSpherical"
    #plotname="jake"
    plotname="cylindrical_test"
    #plotname="manifold_test"
    forcefield_config = {linear_rotation : {"forcefield_type" : linear_rotation}, 
        linear_attractor : {"forcefield_type" : linear_attractor}, 
        linear_rotation_with_attractor : {"forcefield_type" : linear_rotation_with_attractor}, 
        brownean : {"forcefield_type" : brownean}, 
        browneanSpherical : {"forcefield_type" : browneanSpherical},
        browneanSpherical : {"forcefield_type" : browneanSpherical},
        browneanCylindrical : {"forcefield_type" : browneanCylindrical},
        browneanManifold : {"forcefield_type" : browneanManifold}]
    if plotname == "test_3nov2023":
        particle_config = [{"forcefield_type_list":[linear_rotation], "timeout":1, "number_particles":100, "color":"blue"}, {"forcefield_type_list":[linear_rotation_with_attractor], "timeout":1, "number_particles":100, "color":"blue"}, {"forcefield_type_list":[linear_attractor], "timeout":1, "number_particles":100, "color":"blue"}]
    elif plotname == "brownean":
        particle_config = [{"forcefield_type_list":[brownean], "timeout":1, "number_particles":100, "color":"green"}]
    elif plotname == "browneanSpherical":
        particle_config = [
        {"forcefield_type_list":[browneanSpherical], "timeout":1, "number_particles":25, "color":"blue", "radius":50},
        #{"forcefield_type_list":[browneanSpherical], "timeout":1, "number_particles":10, "color":"brown", "radius":52},
        {"forcefield_type_list":[browneanSpherical], "timeout":1, "number_particles":20, "color":"green", "radius":51},
        {"forcefield_type_list":[browneanSpherical], "timeout":1, "number_particles":5, "color":"grey", "radius":57}
        ]
    elif plotname == "jake":
        particle_config = [
        {"forcefield_type_list":[browneanSpherical], "timeout":1, "number_particles":250, "color":"pink", "radius":100}
        ]
    elif plotname == "cylindrical_test":
        particle_config = [{"forcefield_type_list":[browneanCylindrical], "timeout":1, "number_particles":20, "color":"blue", "radius":50},
                           {"forcefield_type_list":[browneanCylindrical], "timeout":1, "number_particles":20, "color":"yellow", "radius":30}]
    elif plotname == "manifold_test":
        particle_config = [{"forcefield_type_list":[browneanManifold], "timeout":1, "number_particles":20, "color":"blue"}]
    ps = particle_systems(forcefield_config, particle_config)
    timesteps = 100
    frames = []
    frames3d = []
    frames_3dtrail=[]
    for i in range(0,timesteps):
        print(f"Timestep {i}/{timesteps}")
        ps.act()
        if i>1:
            frame,frame3d,frame_3dtrail = ps.visualize_frame()
            frame.save(f"results/{plotname}/frame_{i}.png".format(i=i), xmin=-100, xmax=100, ymin=-100, ymax=100)
            frames.append(frame)
            frame3d.save(f"results/{plotname}/frame3d_{i}.png".format(i=i), xmin=-100, xmax=100, ymin=-100, ymax=100, zmin=-100, zmax=100)
            frames3d.append(frame3d)
            frame_3dtrail.save(f"results/{plotname}/frame3dtrail_{i}.png".format(i=i), frame=False, xmin=-100, xmax=100, ymin=-100, ymax=100, zmin=-100, zmax=100)
            frames_3dtrail.append(frame_3dtrail)
    print("animating frames...")
    animate(frames,xmin=-100,xmax=100,ymin=-100, ymax=100, axes=False).save(f'results/{plotname}/plots.gif')
    print("animating frames3d...")
    animate(frames3d, xmin=-100, xmax=100, ymin=-100, ymax=100, zmin=-100, zmax=100, axes=False, frame=False).save(f'results/{plotname}/plots3d.gif')
    print("animating frames_3dtrail...")
    animate(frames_3dtrail, xmin=-100, xmax=100, ymin=-100, ymax=100, zmin=-100, zmax=100, axes=False, frame=False).save(f'results/{plotname}/plots3dtrail.gif')
    #ps.visualize_movie(frames)

if __name__ == "__main__":
    main()
