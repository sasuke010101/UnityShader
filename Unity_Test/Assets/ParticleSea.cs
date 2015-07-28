using UnityEngine;
using System.Collections;

public class ParticleSea : MonoBehaviour {

	public ParticleSystem particleSystem;
	private ParticleSystem.Particle[] particlesArray;

	public int seaResolution = 25;
	public float spacing = 0.25f;

	public float noiseScale = 0.2f;
	public float hightScale = 3f;

	public Gradient colorGradient;

	private float perlinNoiseAnimX = 0.01f;
	private float perlinNoiseAnimY = 0.01f;
	// Use this for initialization
	void Start () {
		particlesArray = new ParticleSystem.Particle[seaResolution * seaResolution];
		particleSystem.maxParticles = seaResolution * seaResolution;
		particleSystem.Emit (seaResolution * seaResolution);
		particleSystem.GetParticles (particlesArray);
	}
	
	// Update is called once per frame
	void Update () {
		for (int i = 0; i < seaResolution; i++) {
			for(int j = 0; j < seaResolution; j++)
			{
				float zPos = Mathf.PerlinNoise(i * noiseScale + perlinNoiseAnimX, j * noiseScale + perlinNoiseAnimY) * hightScale;
				particlesArray[i * seaResolution + j].color = colorGradient.Evaluate(zPos);
				particlesArray[i * seaResolution + j].position = new Vector3(i * spacing, zPos,j * spacing);
			}
			perlinNoiseAnimX += 0.01f;
			perlinNoiseAnimY += 0.01f;
			particleSystem.SetParticles(particlesArray,particlesArray.Length);
		}
		
	}
}
