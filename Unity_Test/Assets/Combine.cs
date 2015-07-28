using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Combine : MonoBehaviour {

	// Use this for initialization
	void Start () {
		Texture blueTex = transform.Find ("CubeBlue").GetComponent<MeshRenderer> ().sharedMaterial.mainTexture;
		Texture orgTex = transform.Find ("CubeOrg").GetComponent<MeshRenderer> ().sharedMaterial.mainTexture;
		Texture redTex = transform.Find ("CubeRed").GetComponent<MeshRenderer> ().sharedMaterial.mainTexture;

		Shader combineShader = Shader.Find("Custom/CombineShader");
		Material combineMaterial = new Material (combineShader);

		combineMaterial.SetTexture ("_Red", redTex);
		combineMaterial.SetTexture ("_Blue", blueTex);
		combineMaterial.SetTexture ("_Org", orgTex);

		MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter> ();
		CombineInstance[] combine = new CombineInstance[meshFilters.Length];
	
		List<Color> combineMeshColor = new List<Color> ();

		for (int i = 0; i < meshFilters.Length; i++)
		{
			combine[i].mesh = meshFilters[i].sharedMesh;
			combine[i].transform = meshFilters[i].transform.localToWorldMatrix;

			Vector2[] UVArray = meshFilters[i].sharedMesh.uv;
			float bodyPart = i / (float)meshFilters.Length;
			for(int uvindex = 0; uvindex < UVArray.Length; uvindex ++)
			{
				combineMeshColor.Add(new Color(bodyPart, bodyPart, bodyPart, bodyPart));
			}

			meshFilters[i].gameObject.SetActive(false);
		}

		Mesh combineMesh = new Mesh ();
		combineMesh.CombineMeshes (combine, true);
		combineMesh.colors = combineMeshColor.ToArray ();
		combineMesh.name = gameObject.name;

		transform.gameObject.AddComponent<MeshRenderer> ();
		transform.gameObject.AddComponent<MeshFilter> ();
		transform.GetComponent<MeshFilter> ().sharedMesh = combineMesh;

		transform.GetComponent<MeshRenderer> ().sharedMaterial = combineMaterial;

		transform.gameObject.SetActive (true);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
