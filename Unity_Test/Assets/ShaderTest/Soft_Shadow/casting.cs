using UnityEngine;
using System.Collections;

public class casting : MonoBehaviour {

	public GameObject occluder;
	
	// Update is called once per frame
	void Update () {
		if(occluder != null)
		{
			this.renderer.sharedMaterial.SetVector("_SpherePosition", occluder.transform.position);

			this.renderer.sharedMaterial.SetFloat("_ShpereRadius", occluder.transform.localScale.x / 2.0f);
		}
	}
}
