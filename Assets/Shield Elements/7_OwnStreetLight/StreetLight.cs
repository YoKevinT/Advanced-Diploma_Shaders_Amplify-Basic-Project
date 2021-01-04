using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StreetLight : MonoBehaviour
{
    private Renderer meshRenderer;
    private Material instanceMaterial;
    private Light lighting;
    public float intensityMultiplier = 5;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        instanceMaterial = meshRenderer.material;
        lighting = GetComponent<Light>();
    }

    void Update()
    {
        lighting.range = instanceMaterial.GetFloat("_Intensity") * intensityMultiplier;
    }
}