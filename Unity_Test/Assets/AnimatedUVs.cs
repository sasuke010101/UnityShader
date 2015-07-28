using UnityEngine;
using System.Collections;

public class AnimatedUVs : MonoBehaviour
{
	public int materialIndex = 0;
	public Vector2 uvAnimationRate = new Vector2(1.0f, 1.0f);
	public string textureName = "_MainTex";

	Vector2 uvOffset = Vector2.zero;

	void LateUpdate()
	{
		uvOffset += (uvAnimationRate * Time.deltaTime);
		if(renderer.enabled)
		{
			renderer.materials[materialIndex].SetTextureOffset(textureName, uvOffset);
		}
	}
}
