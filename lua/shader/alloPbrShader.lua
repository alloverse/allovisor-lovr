-- global, not local! leak this so it lives as long as the shader. 
-- otherwise, it's deallocated before shader is used.
skybox = lovr.graphics.newTexture({
  left = 'assets/env/nx.png',
  right = 'assets/env/px.png',
  top = 'assets/env/py.png',
  bottom = 'assets/env/ny.png',
  back = 'assets/env/pz.png',
  front = 'assets/env/nz.png'
}, { linear = true })

environmentMap = lovr.graphics.newTexture(256, 256, { type = 'cube' })
for mipmap = 1, environmentMap:getMipmapCount() do
  for face, dir in ipairs({ 'px', 'nx', 'py', 'ny', 'pz', 'nz' }) do
    local filename = ('assets/env/m%d_%s.png'):format(mipmap - 1, dir)
    local image = lovr.data.newImage(filename, false)
    environmentMap:replacePixels(image, 0, 0, face, mipmap)
  end
end

local sphericalHarmonics = {
  { 0.375931705762083,  0.358656319030575,  0.308453761543167},
  { 0.354636762547562,  0.351933427534857,  0.346643193593808},
  { 0.213680467209818,  0.208764154253828,  0.185992646424045},
  { 0.094452764555327,  0.087423796528460,  0.078299527458197},
  { 0.129722100892800,  0.126512402478568,  0.121503396241859},
  { 0.236712791137010,  0.233931621210715,  0.222236168254197},
  {-0.020735133497873, -0.020241604203896, -0.018707677741929},
  {-0.073279787762454, -0.073091939150411, -0.068554941014884},
  {-0.102740171078351, -0.099605437423063, -0.094746265045717}
}


local shaders = {
  withNormals = lovr.graphics.newShader(
    'standard',
    {
      flags = {
        highp = true,
        normalMap = true,
        indirectLighting = true,
        occlusion = true,
        emissive = true,
        skipTonemap = false,
        animated = true
      },
      stereo = lovr.headset == nil or (lovr.headset.getName() ~= "Pico") -- turn off stereo on pico: it's not supported
    }
  ),

  withoutNormals = lovr.graphics.newShader(
    'standard',
    {
      flags = {
        highp = true,
        normalMap = false,
        indirectLighting = true,
        occlusion = true,
        emissive = true,
        skipTonemap = false,
        animated = true
      },
      stereo = lovr.headset == nil or (lovr.headset.getName() ~= "Pico") -- turn off stereo on pico: it's not supported
    }
  )
}

for _, shader in pairs(shaders) do
  shader:send('lovrLightDirection', { -1, -1, -1 })
  shader:send('lovrLightColor', { 1, 1, 1, 1.0 })
  shader:send('lovrExposure', 2)
  shader:send('lovrSphericalHarmonics', sphericalHarmonics)
  shader:send('lovrEnvironmentMap', environmentMap)    
end

return shaders
