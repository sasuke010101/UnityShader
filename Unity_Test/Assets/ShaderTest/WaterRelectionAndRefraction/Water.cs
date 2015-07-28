using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
/// <summary>
/// 水面
/// </summary>
[AddComponentMenu("GameCore/Effect/Water/Water (Base)")]
[ExecuteInEditMode]
public class Water : MonoBehaviour
{
	public enum FlageWaterRefType
	{
		Both = 0,
		Reflection = 1,
		Refraction = 2
	}
	public bool DisablePixelLights = false;
	public LayerMask Layers = -1;
	public int TexSize = 512;
	public FlageWaterRefType RefType = FlageWaterRefType.Both;   
	public float ReflectClipPlaneOffset = 0;
	public float RefractionAngle = 0;
	
	private static Camera _reflectionCamera;
	private static Camera _refractionCamera;
	
	private int _OldTexSize = 0;
	private RenderTexture _reflectionRenderTex;
	private RenderTexture _refractionRenderTex;
	
	private bool _insideRendering = false;
	private float _refType = (float)FlageWaterRefType.Both;
	
	void OnWillRenderObject()
	{
		
		if (!enabled || !renderer || !renderer.sharedMaterial || !renderer.enabled)
			return;
		Camera cam = Camera.current;
		if (!cam)
			return;
		Material[] materials = renderer.sharedMaterials;
		if (_insideRendering)
			return;
		_insideRendering = true;
		int oldPixelLightCount = QualitySettings.pixelLightCount;
		if (DisablePixelLights)
			QualitySettings.pixelLightCount = 0;
		if (RefType == FlageWaterRefType.Both || RefType == FlageWaterRefType.Reflection)
		{
			DrawReflectionRenderTexture(cam);
			foreach (Material mat in materials)
			{
				if (mat.HasProperty("_ReflectionTex"))
					mat.SetTexture("_ReflectionTex", _reflectionRenderTex);
			}
		}
		
		if (RefType == FlageWaterRefType.Both || RefType == FlageWaterRefType.Refraction)
		{
			this.gameObject.layer = 4;
			DrawRefractionRenderTexture(cam);
			foreach (Material mat in materials)
			{
				if (mat.HasProperty("_RefractionTex"))
					mat.SetTexture("_RefractionTex", _refractionRenderTex);
			}
		}
		_refType = (float)RefType;
		Matrix4x4 projmtx = CoreTool.UV_Tex2DProj2Tex2D(transform, cam);
		foreach (Material mat in materials)
		{
			mat.SetMatrix("_ProjMatrix", projmtx);
			mat.SetFloat("_RefType", _refType);
		}
		if (DisablePixelLights)
			QualitySettings.pixelLightCount = oldPixelLightCount;
		_insideRendering = false;
	}
	
	/// <summary>
	/// 绘制反射RenderTexture
	/// </summary>
	private void DrawReflectionRenderTexture(Camera cam)
	{
		Vector3 pos = transform.position;
		Vector3 normal = transform.up;
		
		CreateObjects(cam,ref _reflectionRenderTex, ref _reflectionCamera);
		
		CoreTool.CloneCameraModes(cam, _reflectionCamera);
		
		float d = -Vector3.Dot(normal, pos) - ReflectClipPlaneOffset;
		Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);
		
		
		Matrix4x4 reflection = CoreTool.CalculateReflectionMatrix(Matrix4x4.zero, reflectionPlane);
		
		Vector3 oldpos = cam.transform.position;
		Vector3 newpos = reflection.MultiplyPoint(oldpos);
		_reflectionCamera.worldToCameraMatrix = cam.worldToCameraMatrix * reflection;
		
		// Setup oblique projection matrix so that near plane is our reflection
		// plane. This way we clip everything below/above it for free.
		Vector4 clipPlane = CoreTool.CameraSpacePlane(_reflectionCamera, pos, normal, 1.0f, ReflectClipPlaneOffset);
		
		Matrix4x4 projection = cam.projectionMatrix;
		
		projection = CoreTool.CalculateObliqueMatrix(projection, clipPlane, -1);
		
		_reflectionCamera.projectionMatrix = projection;
		
		_reflectionCamera.cullingMask = ~(1 << 4) & Layers.value; // never render water layer
		_reflectionCamera.targetTexture = _reflectionRenderTex;
		
		GL.SetRevertBackfacing(true);
		_reflectionCamera.transform.position = newpos;
		Vector3 euler = cam.transform.eulerAngles;
		_reflectionCamera.transform.eulerAngles = new Vector3(0, euler.y, euler.z);
		_reflectionCamera.Render();
		_reflectionCamera.transform.position = oldpos;
		GL.SetRevertBackfacing(false);
	}
	
	/// <summary>
	/// 绘制折射RenderTexture
	/// </summary>
	private void DrawRefractionRenderTexture(Camera cam)
	{
		CreateObjects(cam, ref _refractionRenderTex, ref _refractionCamera);
		CoreTool.CloneCameraModes(cam, _refractionCamera);
		
		Vector3 pos = transform.position;
		Vector3 normal = transform.up;
		
		Matrix4x4 projection = cam.worldToCameraMatrix;
		projection *= Matrix4x4.Scale(new Vector3(1,Mathf.Clamp(1-RefractionAngle,0.001f,1),1));
		_refractionCamera.worldToCameraMatrix = projection;
		
		Vector4 clipPlane = CoreTool.CameraSpacePlane(_refractionCamera, pos, normal, 1.0f, 0);
		projection = cam.projectionMatrix;
		projection[2] = clipPlane.x + projection[3];//x
		projection[6] = clipPlane.y + projection[7];//y
		projection[10] = clipPlane.z + projection[11];//z
		projection[14] = clipPlane.w + projection[15];//w
		
		_refractionCamera.projectionMatrix = projection;
		
		_refractionCamera.cullingMask = ~(1 << 4) & Layers.value; // never render water layer
		_refractionCamera.targetTexture = _refractionRenderTex;       
		
		_refractionCamera.transform.position = cam.transform.position;
		_refractionCamera.transform.eulerAngles = cam.transform.eulerAngles;
		_refractionCamera.Render();        
	}
	
	void OnDisable()
	{
		if (_reflectionRenderTex)
		{
			DestroyImmediate(_reflectionRenderTex);
			_reflectionRenderTex = null;
		}        
		if (_reflectionCamera)
		{
			DestroyImmediate(_reflectionCamera.gameObject);
			_reflectionCamera = null;
		}
		
		if (_refractionRenderTex)
		{
			DestroyImmediate(_refractionRenderTex);
			_refractionRenderTex = null;
		}
		if (_refractionCamera)
		{
			DestroyImmediate(_refractionCamera.gameObject);
			_refractionCamera = null;
		}        
	}
	
	void CreateObjects(Camera srcCam, ref RenderTexture renderTex, ref Camera destCam)
	{
		// Reflection render texture
		if (!renderTex || _OldTexSize != TexSize)
		{
			if (renderTex)
				DestroyImmediate(renderTex);
			renderTex = new RenderTexture(TexSize, TexSize, 0);
			renderTex.name = "__RefRenderTexture" + renderTex.GetInstanceID();
			renderTex.isPowerOfTwo = true;
			renderTex.hideFlags = HideFlags.DontSave;
			renderTex.antiAliasing = 4;
			renderTex.anisoLevel = 0;
			_OldTexSize = TexSize;
		}
		
		if (!destCam) // catch both not-in-dictionary and in-dictionary-but-deleted-GO
		{
			GameObject go = new GameObject("__RefCamera for " + srcCam.GetInstanceID(), typeof(Camera), typeof(Skybox));
			destCam = go.camera;
			destCam.enabled = false;
			destCam.transform.position = transform.position;
			destCam.transform.rotation = transform.rotation;
			destCam.gameObject.AddComponent("FlareLayer");
			go.hideFlags = HideFlags.HideAndDontSave;
		}
	}
}